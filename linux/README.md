# KinderCare Activities Scraper

A Bash script that automates **downloading activity images and videos** from KinderCare’s `activities` pages.  
It uses [**pup**](https://github.com/ericchiang/pup) to parse the HTML for download links and stores them in a local database (`id.db`) to avoid duplicates.

---

## How It Works

1. **Authentication**  
   - The script reads session cookies from `cookies.txt`.  
   - If the cookies are invalid, you will receive the login page in HTML form instead of the activity listings.

2. **HTML Parsing**  
   - For each page of `activities` (page 1, page 2, etc.), the script:
     1. Downloads the HTML using `wget`.
     2. Uses **pup** to find `<a>` tags that match `title="Download Image"` or `title="Download Video"`, and which contain a `download` attribute.
     3. Extracts the `href` links from those anchors.

3. **Duplicates**  
   - The script keeps a list of downloaded links in `id.db`.
   - If a link is already in `id.db`, it is skipped.

4. **File Storage**  
   - Files are placed in `[scriptdir]/[child_id]/`.
   - You can adjust the naming logic or add steps for post-processing if desired.

---

## Requirements

- **Bash** (version 4.0+)
- **wget**
- **pup** – must be installed and on your `PATH`
- A valid `cookies.txt` with KinderCare login cookies in the same directory

### Installing pup

- **macOS**: `brew install pup`
- **Linux**: Download from [pup GitHub Releases](https://github.com/ericchiang/pup/releases) or use your distro’s packages if available.

### Generating cookies.txt

One approach is:
```bash
wget --save-cookies=cookies.txt \
     --post-data="user[login]=YOUR_EMAIL&user[password]=YOUR_PASSWORD" \
     https://classroom.kindercare.com/login
```
Alternatively, export cookies from your browser’s Developer Tools or using extension https://chromewebstore.google.com/detail/get-cookiestxt-locally/cclelndahbckbenkjhflpdbgdldlbecc 

## Usage
Place cookies.txt in the same directory as the script (unless you modify the script path).
Make the script executable:
```
chmod +x kindercare_download.sh
```
### Run the script:
```
./kindercare_download.sh [options]
Options
-k CHILD_ID: ID of the child’s account to scrape. (Defaults to 589168 in the script.)
-i: “No insert” – skip appending new links to id.db.
-c: Placeholder to set caption=1 (not fully implemented in the sample).
```
#### Example
```
./kindercare_download.sh -k 123456
```
This command will start scraping https://classroom.kindercare.com/accounts/123456/activities?page=1, page 2, etc.
Downloads new “Download Image” or “Download Video” links into the folder 123456/.
Deduplicates links using the local database file 123456/id.db.
## Project Layout
```
.
├── kindercare_download.sh       # Main script
├── cookies.txt                  # KinderCare cookies
├── README.md                    # This file
└── <child_id>/                      # Child ID folder (example)
    ├── id.db                    # Database of downloaded links
    └── big_1234abcd.jpg         # Example downloaded file(s)
```

## Contributing
Fork this repository.
Create a feature branch, e.g., git checkout -b feature/download-enhancements.
Commit your changes: git commit -am "Add new feature".
Push to your branch: git push origin feature/download-enhancements.
Open a Pull Request on GitHub.
