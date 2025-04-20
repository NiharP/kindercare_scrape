# KinderCare Media Downloader

This script downloads all images and videos from the KinderCare parental portal for your child's account. It allows you to keep a personal archive of your child's memories and activities.

## Prerequisites

- Python 3.6 or higher
- Git (for cloning the repository)
- Chrome browser (for the cookie extension)

## Setup Instructions

1. **Clone or download this repository**

   ```bash
   git clone https://github.com/NiharP/kindercare_scrape.git
   cd kindercare_scrape/

   If you are using mac,
   cd mac

   If you are using linux,
   cd linux
   ```

2. **Install Dependencies**

   Using the included Makefile:
   ```bash
   make setup
   ```

2. **Install the "Get cookies.txt LOCALLY" Chrome Extension**

   - Go to the Chrome Web Store and search for "Get cookies.txt LOCALLY" or use this link: [Get cookies.txt LOCALLY](https://chrome.google.com/webstore/detail/get-cookiestxt-locally/cclelndahbckbenkjhflpdbgdldlbecc)
   - Click "Add to Chrome" to install the extension
   - You should see a cookie icon in your browser extensions area

3. **Export Cookies from KinderCare Portal**

   - Log in to your KinderCare parental portal
   - After successfully logging in, click on the "Get cookies.txt LOCALLY" extension icon
   - In the popup window, click on "Export" to download the cookies.txt file
   - Save the cookies.txt file in the same directory as the script

4. **Get childid**
   - You can get the childid from https://classroom.kindercare.com/accounts/<childid>


## Usage

1. **Place your cookies.txt file in the project directory**
2. **Update childid in makefile
3. **Run the script using the Makefile:**

   With default settings:
   ```bash
   make all
   ```
## Output

The script will create a folder structure like:

```
kindercare_media/
├── childid/
│   ├── 20230115_01234.jpg
└── child_name_2/
    └── 20230115_01234.jpg
```

## Troubleshooting

- **Authentication Issues**: Make sure you've exported cookies while logged in to the KinderCare portal
- **Download Errors**: Check your internet connection and try again
- **Permission Errors**: Ensure the script has write permissions to the output directory
- **Dependency Issues**: Run `make setup` to ensure all dependencies are installed correctly
- **Makefile Errors**: On Windows, you may need to install Make separately or use the Python commands directly

## Project Structure

```
kindercare-downloader/
├── kindercare_downloader.sh  # Main script
├── Makefile                  # Automation for common tasks
├── README.md                 # This file
└── cookies.txt               # Your exported cookies (you need to create this)
```

## Notes

- This script respects KinderCare's servers by using reasonable delays between requests
- Only use this to download your own child's media for personal use
- Your login session may expire after some time, requiring you to generate a new cookies.txt file
- For help with available commands, run `make help`

## Disclaimer

This tool is for personal use only to download your own child's media content. Please respect KinderCare's terms of service and only use this script for personal archiving purposes.