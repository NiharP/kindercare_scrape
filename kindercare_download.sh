#!/usr/bin/env bash

###############################################################################
# KinderCare Activities Scraper
# Loops over pages for a given child_id, downloads HTML, extracts the
# "Download Image" or "Download Video" links, and downloads them. Each link is
# deduplicated based on a local ID database.
###############################################################################

child_id="xxxxx"  # Default child ID
no_insert_db=0
caption=0
usage() {
    echo "Usage: $0 [-cik xxxxxx]"
    echo "  -c   Enable caption=1 (unused placeholder in this script)"
    echo "  -i   Do not insert new links into id.db (no_insert_db=1)"
    echo "  -k x Child ID"
    exit 1
}

exit_abnormal() {
    usage
    exit 1
}

# Parse arguments
while getopts "cik:" o; do
    case "${o}" in
        c)
            caption=1
            ;;
        i)
            no_insert_db=1
            ;;
        k)
            child_id=${OPTARG}
            ;;
        :)
            echo "Error: -${OPTARG} requires an argument."
            exit_abnormal
            ;;
        *)
            exit_abnormal
            ;;
    esac
done

# Directory to hold downloaded files + an ID database
DOWNLOAD_DIR="$(dirname "$0")/${child_id}"
DB_FILE="${DOWNLOAD_DIR}/id.db"
TMPDIR="/tmp/_${child_id}"

# Prepare directories and db
if [ ! -s "$DB_FILE" ]; then
    mkdir -p "$DOWNLOAD_DIR"
    mkdir -p "$TMPDIR"
    touch "$DB_FILE"
fi

# We'll iterate pages until no more new links appear or no more pages
k=1
done=0

while [ "$done" != "1" ]; do
    echo "==== Fetching page $k for child $child_id ===="
    PAGE_HTML="${TMPDIR}/page_${k}.html"
    wget -q --load-cookies "$(dirname "$0")/cookies.txt" \
         "https://classroom.kindercare.com/accounts/${child_id}/activities?page=${k}" \
         -O "$PAGE_HTML"

    # Check if the page is empty or the site might have returned a login page
    if [ ! -s "$PAGE_HTML" ]; then
        echo "Empty or invalid response. Stopping."
        done=1
        break
    fi

    # Use pup to find all anchors with `title="Download Image"` or `title="Download Video"`
    # which also have a `download` attribute. Extract just the href link.
    LINKS_FILE="${TMPDIR}/links_${k}.txt"
    pup 'a[title="Download Image"][download], a[title="Download Video"][download] attr{href}' < "$PAGE_HTML" > "$LINKS_FILE"

    # If no links found, we assume no more pages or no data
    num_links=$(wc -l < "$LINKS_FILE")
    if [ "$num_links" -eq 0 ]; then
        echo "No (new) links found on page $k. Stopping."
        done=1
    else
        # Sort them to compare with DB, find new ones
        sort "$LINKS_FILE" > "${TMPDIR}/links_sorted_${k}.txt"

        # Compare with existing DB to get only new lines
        comm -23 "${TMPDIR}/links_sorted_${k}.txt" "$DB_FILE" > "${TMPDIR}/delta_${k}.txt"
        new_count=$(wc -l < "${TMPDIR}/delta_${k}.txt")

        if [ "$new_count" -eq 0 ]; then
            echo "All links on page $k are already downloaded. Stopping."
            done=1
        else
            echo "Found $new_count new links on page $k. Downloading..."

            # Download each new link
            i=1
            while read -r LINK; do
                # Extract a name from the link (e.g. the ?download= param or final path)
                # We remove querystring for a cleaner name
                BASENAME="$(basename "$LINK" | cut -d'?' -f1)"
                
                # You can optionally parse "download=" from the URL if needed.
                # We'll just do:
                OUTFILE="${DOWNLOAD_DIR}/${BASENAME}"

                echo "[$i] Downloading => $OUTFILE"
                wget -q --load-cookies "$(dirname "$0")/cookies.txt" \
                     -O "$OUTFILE" \
                     "$LINK"

                # If you want to do any post-processing with exiftool or ffmpeg,
                # you'd check if $OUTFILE is an image or a .MOV etc.

                ((i++))
            done < "${TMPDIR}/delta_${k}.txt"

            # If we do want to update the DB:
            if [ "$no_insert_db" = "0" ]; then
                cat "${TMPDIR}/delta_${k}.txt" >> "$DB_FILE"
                sort -u "$DB_FILE" -o "$DB_FILE"
            fi
        fi
    fi

    # Cleanup for this page
    rm -f "$PAGE_HTML" "$LINKS_FILE" "${TMPDIR}/links_sorted_${k}.txt" "${TMPDIR}/delta_${k}.txt"

    # Move on to next page if not done
    ((k++))
done

echo "Done scraping child $child_id."
exit 0
