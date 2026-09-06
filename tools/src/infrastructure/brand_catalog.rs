//! brands/*.yaml → Brand 모델. 와이어 형식(YAML 키)은 이 파일 밖으로 나가지 않는다.

use std::path::{Path, PathBuf};

use anyhow::Result;

use crate::domain::brand::Brand;

pub struct YamlBrandCatalog {
    directory: PathBuf,
    logo_directory: PathBuf,
}

impl YamlBrandCatalog {
    pub fn new(directory: impl AsRef<Path>, logo_directory: impl AsRef<Path>) -> Self {
        Self { directory: directory.as_ref().to_path_buf(),
               logo_directory: logo_directory.as_ref().to_path_buf() }
    }

    pub fn load(&self) -> Result<Vec<Brand>> {
        let mut paths: Vec<PathBuf> = std::fs::read_dir(&self.directory)?
            .filter_map(|entry| entry.ok().map(|e| e.path()))
            .filter(|path| path.extension().and_then(|e| e.to_str()) == Some("yaml"))
            .collect();
        paths.sort();

        let mut brands = Vec::new();
        for path in paths {
            let mut brand: Brand = serde_yaml::from_str(&std::fs::read_to_string(&path)?)?;
            let logo = self.logo_directory.join(format!("{}.png", brand.key));
            brand.logo_path = logo.exists().then_some(logo);
            brands.push(brand);
        }
        Ok(brands)
    }
}
