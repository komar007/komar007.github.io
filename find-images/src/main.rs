use std::{env::args, error::Error, fs::read_to_string, process::Command, str::FromStr};

use ctreg::regex;
use pulldown_cmark::{Event, Parser, Tag};
use rayon::prelude::*;
use url::Url;

fn md_thumbs(md: &str) -> impl Iterator<Item = Thumb> {
    let parser = Parser::new(md);
    parser.filter_map(move |event| {
        let Event::Start(Tag::Image { dest_url, .. }) = event else {
            return None;
        };
        dest_url.parse().ok()
    })
}

#[derive(Debug, PartialEq, Eq)]
struct Thumb {
    self_path: String,
    source_path: String,
    magick_geometry: Option<String>,
}

impl FromStr for Thumb {
    type Err = ();

    fn from_str(value: &str) -> Result<Self, Self::Err> {
        regex! {
            pub ThumbSpec = r"(?<thumb>(?<stem>.*)_thumb(_(?<magick>[0-9]*x[0-9]*))?\.(?<ext>.*))"
        };
        let re = ThumbSpec::new();
        let captures = re.captures(value).ok_or(())?;
        let magick = captures.magick.map(|m| m.content);
        Ok(Self {
            self_path: captures.thumb.content.to_string(),
            source_path: format!("{}.{}", captures.stem.content, captures.ext.content),
            magick_geometry: magick.map(ToString::to_string),
        })
    }
}

fn main() -> Result<(), Box<dyn Error>> {
    let mut jobs = vec![];
    for file in args().skip(1) {
        let md = read_to_string(&file)?;
        let base = Url::parse(&format!("http://dummy/{file}"))?;
        for thumb in md_thumbs(&md) {
            let self_path = base.join(&thumb.self_path)?;
            let self_path = self_path.path()[1..].to_owned();
            let source_path = base.join(&thumb.source_path)?;
            let source_path = source_path.path()[1..].to_owned();
            let geometry = thumb.magick_geometry.unwrap_or("455x".to_owned());
            jobs.push((source_path, self_path, geometry));
        }
    }
    let outs: Result<Vec<_>, _> = jobs
        .par_iter()
        .map(|(from, to, geometry)| {
            println!("{from} -> {to}");
            Command::new("magick")
                .args([from, "-resize", geometry, to])
                .output()
        })
        .collect();
    outs?.iter().try_for_each(|out| {
        out.status.success().then_some(()).ok_or_else(|| {
            std::io::Error::other(format!(
                "magick exited with error: {}",
                String::from_utf8_lossy(&out.stderr)
            ))
        })
    })?;
    Ok(())
}

#[cfg(test)]
mod test {
    use crate::{Thumb, md_thumbs};

    #[test]
    fn finds() {
        let md = r#"![Logo](assets/logo_thumb_200x300.png "jjj")"#;
        assert_eq!(
            md_thumbs(md).next().unwrap(),
            Thumb {
                self_path: "assets/logo_thumb_200x300.png".to_string(),
                source_path: "assets/logo.png".to_string(),
                magick_geometry: Some("200x300".to_string())
            }
        );
        let md = r#"![Logo](assets/logo_thumb.png "jjj")"#;
        assert_eq!(
            md_thumbs(md).next().unwrap(),
            Thumb {
                self_path: "assets/logo_thumb.png".to_string(),
                source_path: "assets/logo.png".to_string(),
                magick_geometry: None,
            }
        );
        let md = r#"![Logo](assets/logo_thumb_.png "jjj")"#;
        assert!(md_thumbs(md).next().is_none());
    }
}
