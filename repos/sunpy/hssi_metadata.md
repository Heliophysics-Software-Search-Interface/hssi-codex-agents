# HSSI Metadata Extraction Results

**Repository:** /Users/shpo9723/git/hssi-codex-agents/repos/sunpy (canonical URL: https://github.com/sunpy/sunpy)
**Extraction Date:** 2026-02-19

---

## Section 1: Basic Information

### 1. Submitter (MANDATORY)
- **Submitter Name:** [To be filled by actual submitter]
- **Submitter Email:** [To be filled by actual submitter]

### 2. Persistent Identifier (RECOMMENDED)
- **Value:** https://doi.org/10.5281/zenodo.591887
- **Source:** `sunpy/CITATION.rst` (Zenodo DOI) and Zenodo API record `17857260` (`conceptdoi`).

### 3. Code Repository (MANDATORY)
- **Value:** https://github.com/sunpy/sunpy
- **Source:** `pyproject.toml` (`[project.urls] Source Code`), SoMEF `code_repository`, PyHC `projects_core.yml`.

### 4. Software Functionality (MANDATORY)
- **Values:**
  - Coordinate Transforms
  - Coordinate Transforms: Heliospheric
  - Coordinate Transforms: Magnetospheric
  - Coordinate Transforms: Solar
  - Data Processing and Analysis
  - Data Processing and Analysis: Analysis
  - Data Processing and Analysis: Data Access and Retrieval
  - Data Processing and Analysis: File Format Conversion
  - Data Processing and Analysis: Image Processing
  - Data Processing and Analysis: Processing
  - Data Processing and Analysis: Time Series Analysis
  - Data Visualization
  - Data Visualization: 2D Graphics
  - Data Visualization: Line Plots
  - Data Visualization: Movies
- **Source:** `sunpy/coordinates/frames.py` (solar/heliospheric + magnetospheric frame classes), `docs/tutorial/acquiring_data/index.rst` (`Fido` unified retrieval), `sunpy/map/mapbase.py` (processing + format conversion + plotting), `docs/tutorial/timeseries.rst` (time-series analysis/plotting), `sunpy/map/mapsequence.py` + `sunpy/visualization/animator/` (animations).

### 5. Related Region (MANDATORY)
- **Values:**
  - Solar Environment
  - Interplanetary Space
- **Source:** `README.rst` (“Python for solar physics”), `sunpy/coordinates/frames.py` (heliocentric/heliospheric frames), PyHC `projects_core.yml` keywords (includes `solar`, `heliosphere`), and map sources for missions such as PSP/Solar Orbiter.

### 6. Authors (MANDATORY)
- **Values:**
  - **Author:** The SunPy Community
  - **Author:** Stuart J. Mumford
    - **Author Identifier:** https://orcid.org/0000-0003-4217-4642
    - **Affiliation:** Aperio Software Ltd.
  - **Author:** Nabil Freij
    - **Author Identifier:** https://orcid.org/0000-0002-6253-082X
    - **Affiliation:** SETI Institute & Lockheed Martin Solar and Astrophysics Laboratory
  - **Author:** David Stansby
    - **Author Identifier:** https://orcid.org/0000-0002-1365-1908
    - **Affiliation:** University College London
  - **Author:** Albert Y. Shih
    - **Author Identifier:** https://orcid.org/0000-0001-6874-2594
    - **Affiliation:** NASA Goddard Space Flight Center
  - **Author:** Steven Christe
    - **Author Identifier:** https://orcid.org/0000-0001-6127-795X
    - **Affiliation:** NASA Goddard Space Flight Center
  - **Author:** Jack Ireland
    - **Author Identifier:** https://orcid.org/0000-0002-2019-8881
    - **Affiliation:** NASA Goddard Space Flight Center
  - **Author:** V. Keith Hughitt
    - **Author Identifier:** https://orcid.org/0000-0003-0787-9559
    - **Affiliation:** Center for Cancer Research, National Cancer Institute
  - **Author:** Daniel F. Ryan
    - **Author Identifier:** https://orcid.org/0000-0001-8661-3825
    - **Affiliation:** University College London, Mullard Space Science Laboratory (UCL/MSSL)
  - **Author:** Will Barnes
    - **Author Identifier:** https://orcid.org/0000-0001-9642-6089
    - **Affiliation:** American University & NASA Goddard Space Flight Center
  - **Author:** Laura Hayes
    - **Author Identifier:** https://orcid.org/0000-0002-6835-2390
    - **Affiliation:** Dublin Institute for Advanced Studies
  - **Additional contributors:** Full release creator list available in Zenodo record (261 creators for v7.1.0).
- **Source:** `.zenodo.json` creators, DataCite for `10.5281/zenodo.17857260`, and `CITATION.cff`.

### 7. Software Name (MANDATORY)
- **Value:** sunpy
- **Source:** `pyproject.toml` (`[project] name`), SoMEF `name`, PyHC `projects_core.yml` entry `SunPy`.

### 8. Description (MANDATORY)
- **Value:** SunPy is a Python software package providing core tools for solar physics and heliophysics data workflows, including data search/download, coordinate transforms, map and time-series data structures, and visualization utilities.
- **Source:** `README.rst` package description, `pyproject.toml` description, SoMEF description candidates.

### 9. Concise Description (OPTIONAL)
- **Value:** SunPy is a Python library for solar/heliophysics data access, coordinate transforms, map/time-series handling, and visualization through a unified interface.
- **Source:** Condensed from `README.rst` and `pyproject.toml` descriptions.

### 10. Publication Date (RECOMMENDED)
- **Value:** 2011-08-06
- **Source:** SoMEF/GitHub metadata (`date_created`) for repository creation date.

### 11. Publisher (RECOMMENDED)
- **Organization:** Zenodo
- **Publisher Identifier:** https://zenodo.org
- **Source:** DataCite metadata for `10.5281/zenodo.591887` and `10.5281/zenodo.17857260` (`publisher=Zenodo`).

### 12. Version (RECOMMENDED)
- **Version Number:** v7.1.0
- **Version Date:** 2025-12-08
- **Version Description:** Stable release with dependency baseline updates, new SOLARNET/Fido and map-source capabilities, and multiple fixes across coordinates, net clients, and map/time-series workflows.
- **Version PID:** https://doi.org/10.5281/zenodo.17857260
- **Source:** `CHANGELOG.rst` (`7.1.0 (2025-12-08)`), Zenodo/DataCite metadata, SoMEF release extraction.

### 13. Programming Language (RECOMMENDED)
- **Values:**
  - Python 3.x
  - C
  - IDL
- **Source:** `pyproject.toml` Python classifiers, SoMEF/GitHub language extraction.

### 14. Reference Publication (RECOMMENDED)
- **Value:** https://doi.org/10.3847/1538-4357/ab4f7a
- **Source:** `CITATION.cff`, `sunpy/CITATION.rst`, `docs/references.bib` (`the_sunpy_community_sunpy_2020`).

### 15. License (RECOMMENDED)
- **License:** BSD 2-Clause "Simplified" License
- **License URI:** https://opensource.org/licenses/BSD-2-Clause
- **Source:** DataCite rights list for Zenodo DOI; `LICENSE.rst` text is BSD-2-style terms.

## Section 2: Additional Data

### 16. Keywords (OPTIONAL)
- **Values:**
  - solar
  - heliosphere
  - coordinates
  - data_retrieval
  - data_analysis
  - image_processing
  - line_plots
  - fits
  - netcdf
  - cdaweb
  - fido
  - goes
  - soho
  - lasco
  - python
- **Source:** PyHC curated `projects_core.yml` keywords (priority source), with minor normalization for readability.

### 17. Data Sources (OPTIONAL)
- **Values:**
  - CDAWeb
  - The Virtual Solar Observatory.
  - Observatory/Mission-specific
  - HTTP/HTTPS Directories
  - FTP/FTPS Directories
- **Source:** `docs/tutorial/acquiring_data/index.rst` client table (`CDAWEBClient`, `VSOClient`, mission-specific clients such as JSOC/SOLARNET/HEK); `CHANGELOG.rst` notes `sunpy.net.scraper` remote HTTP/FTP behavior.

### 18. Input File Formats (RECOMMENDED)
- **Values:**
  - FITS
  - CDF
  - HDF5
  - netCDF3/4
  - JSON
  - ISTP-Compliant
  - Other
- **Source:** `sunpy/io/_file_tools.py` file detection (FITS/JP2/ANA/HDF5/CDF/ASDF), `docs/reference/timeseries.rst` (CDF + Space Physics CDF guidance), `sunpy/timeseries/sources/goes.py` (FITS and netCDF parsing), `sunpy/timeseries/sources/noaa.py` (JSON).

### 19. Output File Formats (RECOMMENDED)
- **Values:**
  - FITS
  - Other
- **Source:** `sunpy/map/mapbase.py::save` (supports FITS, JP2, ASDF).

### 20. Operating System (RECOMMENDED)
- **Values:**
  - Linux
  - Mac
  - Windows
  - Operating System Independent
- **Source:** `.github/workflows/ci.yml` test matrix and wheel targets; `pyproject.toml` classifier `Operating System :: OS Independent`.

### 21. CPU Architecture (RECOMMENDED)
- **Values:**
  - x86-64
  - Apple Silicon arm64
  - Linux aarch64 or arm64
- **Source:** `.github/workflows/ci.yml` publish wheel targets (`manylinux*_x86_64`, `macosx_arm64`, `manylinux_aarch64`, `win_amd64`).

### 22. Related Phenomena (OPTIONAL)
- **Values:**
  - Solar Corona
  - Solar Flares
  - X-ray emission
  - Coronal Mass Ejections
- **Source:** Package scope in `README.rst` (solar physics), tutorial examples and supported sources/instruments (AIA/EUV, GOES XRS, RHESSI, SOHO/LASCO-related map/data support).

### 23. Development Status (RECOMMENDED)
- **Value:** Active
- **Source:** `README.rst` badge `Project Status: Active`; ongoing releases in `CHANGELOG.rst` (latest stable release 2025-12-08).

### 24. Documentation (RECOMMENDED)
- **Value:** https://docs.sunpy.org
- **Source:** `pyproject.toml` project URLs; SoMEF documentation extraction.

### 25. Funder (OPTIONAL)
- **Value:** Not found
- **Source:** No explicit funder metadata in Zenodo/DataCite record fields for extracted software DOI and no unambiguous repository-level funding block for this release metadata.

### 26. Award Title (OPTIONAL)
- **Value:** Not found
- **Source:** No award title/number in DataCite funding references for extracted software DOI.

## Section 3: Additional Metadata

### 27. Related Publications (OPTIONAL)
- **Values:**
  - https://doi.org/10.21105/joss.01832
  - https://doi.org/10.1088/1749-4699/8/1/014009
- **Source:** `docs/references.bib` entries `mumford_sunpy_2020` and `sunpy_community_sunpypython_2015`; also referenced from `sunpy/CITATION.rst`.

### 28. Related Datasets (OPTIONAL)
- **Value:** Not found
- **Source:** Repository metadata and DOI records reviewed; no single authoritative dataset DOI list provided for this software package metadata.

### 29. Related Software (OPTIONAL)
- **Values:**
  - https://github.com/astropy/astropy
- **Source:** Core dependency and direct API integration visible across source imports (e.g., `astropy.coordinates`, `astropy.wcs`, `astropy.units`) and `pyproject.toml` dependencies.

### 30. Interoperable Software (OPTIONAL)
- **Value:** Not found
- **Source:** No explicit, curated interoperability list provided in repository metadata beyond general ecosystem references.

### 31. Related Instruments (OPTIONAL)
- **Values:**
  - **Instrument Name:** AIA
    - **Instrument Identifier:** Not found
  - **Instrument Name:** HMI
    - **Instrument Identifier:** Not found
  - **Instrument Name:** EVE
    - **Instrument Identifier:** Not found
  - **Instrument Name:** XRS
    - **Instrument Identifier:** Not found
  - **Instrument Name:** SUVI
    - **Instrument Identifier:** Not found
  - **Instrument Name:** LYRA
    - **Instrument Identifier:** Not found
  - **Instrument Name:** RHESSI
    - **Instrument Identifier:** Not found
  - **Instrument Name:** GBM
    - **Instrument Identifier:** Not found
  - **Instrument Name:** EIT
    - **Instrument Identifier:** Not found
  - **Instrument Name:** LASCO
    - **Instrument Identifier:** Not found
  - **Instrument Name:** HXI
    - **Instrument Identifier:** Not found
- **Source:** `docs/tutorial/acquiring_data/index.rst` provider table; `sunpy/timeseries/sources/__init__.py`; mission/instrument-specific map sources under `sunpy/map/sources/`.

### 32. Related Observatories (OPTIONAL)
- **Values:**
  - SDO
  - SOHO
  - STEREO
  - Solar Orbiter
  - Parker Solar Probe
  - PROBA2
  - Hinode
  - IRIS
  - Yohkoh
  - MLSO
  - GONG
- **Source:** `sunpy/map/sources/` mission source modules (`sdo.py`, `soho.py`, `stereo.py`, `solo.py`, `psp.py`, `proba2.py`, `hinode.py`, `iris.py`, `yohkoh.py`, `mlso.py`, `gong.py`) and tutorials/examples.

### 33. Logo (OPTIONAL)
- **Value:** https://raw.githubusercontent.com/sunpy/sunpy-logo/master/generated/sunpy_icon.png
- **Source:** PyHC curated metadata (`projects_core.yml` `logo` field).
