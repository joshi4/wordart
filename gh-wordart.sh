#!/usr/bin/env bash

# GitHub Word Art Generator
# Creates commits on specific dates to spell words on GitHub's contribution chart
#
# Cross-platform compatibility:
# - Works on Linux (GNU date), macOS (BSD date), and systems with GNU coreutils (gdate)
# - Automatically detects and uses appropriate date command syntax

set -e

# Function to get character pattern
get_pattern() {
    local char="$1"
    case "$char" in
        "A") echo "01110 10001 10001 11111 10001 10001 10001" ;;
        "B") echo "11110 10001 10001 11110 10001 10001 11110" ;;
        "C") echo "01111 10000 10000 10000 10000 10000 01111" ;;
        "D") echo "11110 10001 10001 10001 10001 10001 11110" ;;
        "E") echo "11111 10000 10000 11110 10000 10000 11111" ;;
        "F") echo "11111 10000 10000 11110 10000 10000 10000" ;;
        "G") echo "01111 10000 10000 10011 10001 10001 01111" ;;
        "H") echo "10001 10001 10001 11111 10001 10001 10001" ;;
        "I") echo "11111 00100 00100 00100 00100 00100 11111" ;;
        "J") echo "11111 00010 00010 00010 00010 10010 01100" ;;
        "K") echo "10001 10010 10100 11000 10100 10010 10001" ;;
        "L") echo "10000 10000 10000 10000 10000 10000 11111" ;;
        "M") echo "10001 11011 10101 10001 10001 10001 10001" ;;
        "N") echo "10001 11001 10101 10011 10001 10001 10001" ;;
        "O") echo "01110 10001 10001 10001 10001 10001 01110" ;;
        "P") echo "11110 10001 10001 11110 10000 10000 10000" ;;
        "Q") echo "01110 10001 10001 10001 10101 10010 01101" ;;
        "R") echo "11110 10001 10001 11110 10100 10010 10001" ;;
        "S") echo "01111 10000 10000 01110 00001 00001 11110" ;;
        "T") echo "11111 00100 00100 00100 00100 00100 00100" ;;
        "U") echo "10001 10001 10001 10001 10001 10001 01110" ;;
        "V") echo "10001 10001 10001 10001 10001 01010 00100" ;;
        "W") echo "10001 10001 10001 10001 10101 11011 10001" ;;
        "X") echo "10001 01010 00100 00100 00100 01010 10001" ;;
        "Y") echo "10001 10001 01010 00100 00100 00100 00100" ;;
        "Z") echo "11111 00010 00100 01000 10000 10000 11111" ;;
        "0") echo "01110 10001 10011 10101 11001 10001 01110" ;;
        "1") echo "00100 01100 00100 00100 00100 00100 01110" ;;
        "2") echo "01110 10001 00001 00110 01000 10000 11111" ;;
        "3") echo "11111 00010 00100 00110 00001 10001 01110" ;;
        "4") echo "00010 00110 01010 10010 11111 00010 00010" ;;
        "5") echo "11111 10000 11110 00001 00001 10001 01110" ;;
        "6") echo "00110 01000 10000 11110 10001 10001 01110" ;;
        "7") echo "11111 00001 00010 00100 01000 10000 10000" ;;
        "8") echo "01110 10001 10001 01110 10001 10001 01110" ;;
        "9") echo "01110 10001 10001 01111 00001 00010 01100" ;;
        " ") echo "00000 00000 00000 00000 00000 00000 00000" ;;
        *) echo "" ;;
    esac
}

# Function to get the day of week for a given date (0=Sunday, 6=Saturday)
get_day_of_week() {
    local date_str="$1"
    # Try GNU date first (Linux), then BSD date (macOS)
    if date -d "$date_str" +%w 2>/dev/null; then
        return
    elif date -j -f "%Y-%m-%d" "$date_str" +%w 2>/dev/null; then
        return
    else
        echo "Error: Unable to parse date $date_str" >&2
        exit 1
    fi
}

# Function to get date N days ago
get_date_n_days_ago() {
    local days="$1"
    # Try GNU date first (Linux/gdate), then BSD date (macOS)
    if command -v gdate >/dev/null 2>&1; then
        gdate -d "$days days ago" +%Y-%m-%d
    elif date -d "$days days ago" +%Y-%m-%d 2>/dev/null; then
        return
    elif date -v-"$days"d +%Y-%m-%d 2>/dev/null; then
        return
    else
        echo "Error: Unable to calculate date $days days ago" >&2
        exit 1
    fi
}

# Function to get date N days from a reference date
get_date_offset() {
    local ref_date="$1"
    local offset="$2"
    # Try GNU date first (Linux/gdate), then BSD date (macOS)
    if command -v gdate >/dev/null 2>&1; then
        gdate -d "$ref_date + $offset days" +%Y-%m-%d
    elif date -d "$ref_date + $offset days" +%Y-%m-%d 2>/dev/null; then
        return
    elif date -v+"$offset"d -j -f "%Y-%m-%d" "$ref_date" +%Y-%m-%d 2>/dev/null; then
        return
    else
        echo "Error: Unable to calculate date $offset days from $ref_date" >&2
        exit 1
    fi
}

# Function to create a commit on a specific date
create_commit_on_date() {
    local commit_date="$1"
    local commit_count="$2"
    local char="$3"
    local col="$4"
    local row="$5"
    local message="Word art: '$char' (col:$col, row:$row) - $commit_date"

    # Use a more efficient approach: create commits in smaller batches
    local batch_size=25
    local full_batches=$((commit_count / batch_size))
    local remaining=$((commit_count % batch_size))

    # Create full batches
    for ((batch=0; batch<full_batches; batch++)); do
        local i
        for ((i=1; i<=batch_size; i++)); do
            local commit_num=$((batch * batch_size + i))
            local time_offset=$((commit_num % 60))
            local formatted_time_offset=$(printf "%02d" $time_offset)
            GIT_AUTHOR_DATE="$commit_date 12:00:$formatted_time_offset" GIT_COMMITTER_DATE="$commit_date 12:00:$formatted_time_offset" \
                git commit --allow-empty -m "$message #$commit_num" --quiet --no-gpg-sign
        done
    done

    # Create remaining commits
    if [[ $remaining -gt 0 ]]; then
        local i
        for ((i=1; i<=remaining; i++)); do
            local commit_num=$((full_batches * batch_size + i))
            local time_offset=$((commit_num % 60))
            local formatted_time_offset=$(printf "%02d" $time_offset)
            GIT_AUTHOR_DATE="$commit_date 12:00:$formatted_time_offset" GIT_COMMITTER_DATE="$commit_date 12:00:$formatted_time_offset" \
                git commit --allow-empty -m "$message #$commit_num" --quiet --no-gpg-sign
        done
    fi
}

# Function to render a character at a specific column offset
render_character() {
    local char="$1"
    local start_col="$2"
    local start_date="$3"
    local num_commits="$4"

    # Get the pattern for this character
    local pattern
    pattern=$(get_pattern "$char")
    if [[ -z "$pattern" ]]; then
        echo "Warning: No pattern found for character '$char', skipping..."
        return
    fi

    # Split pattern into rows without modifying IFS
    local rows=($pattern)

    # For each column (0-4) in the character
    for col in {0..4}; do
        local current_col=$((start_col + col))

        # For each row (0-6, representing Sunday to Saturday)
        for row in {0..6}; do
            local row_pattern="${rows[$row]}"
            local bit="${row_pattern:$col:1}"

            if [[ "$bit" == "1" ]]; then
                # Calculate the date for this position
                local days_offset=$((current_col * 7 + row))
                local commit_date
                commit_date=$(get_date_offset "$start_date" "$days_offset")

                # Create commits on this date using the specified number of commits
                create_commit_on_date "$commit_date" "$num_commits" "$char" "$col" "$row"
            fi
        done
    done
}

# Parse command line arguments
parse_args() {
    local github_username=""
    local word=""
    local num_commits=45
    local year=$(date +%Y)

    while [[ $# -gt 0 ]]; do
        case $1 in
            --num-commits)
                num_commits="$2"
                if ! [[ "$num_commits" =~ ^[0-9]+$ ]]; then
                    echo "Error: --num-commits must be an integer"
                    exit 1
                fi
                shift 2
                ;;
            --year)
                year="$2"
                if ! [[ "$year" =~ ^[0-9]{4}$ ]]; then
                    echo "Error: --year must be a 4-digit year"
                    exit 1
                fi
                shift 2
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            -*)
                echo "Error: Unknown option $1"
                show_usage
                exit 1
                ;;
            *)
                if [[ -z "$github_username" ]]; then
                    github_username="$1"
                elif [[ -z "$word" ]]; then
                    word="$1"
                else
                    echo "Error: Too many arguments"
                    show_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done

    if [[ -z "$github_username" || -z "$word" ]]; then
        echo "Error: Missing required arguments"
        show_usage
        exit 1
    fi

    printf '%s/%s/%s/%s/' "$github_username" "$word" "$num_commits" "$year"
}

# Show usage information
show_usage() {
    echo "Usage: $0 [OPTIONS] <github_username> <word>"
    echo ""
    echo "Arguments:"
    echo "  github_username    Your GitHub username"
    echo "  word               Word to render (max 8 characters, A-Z, 0-9, spaces)"
    echo ""
    echo "Options:"
    echo "  --num-commits N   Number of commits per active day (default: 45)"
    echo "  --year YYYY       Target year for the art (default: current year)"
    echo "                    Past year: Jan 1 to Dec 31 of that year"
    echo "                    Current year: From today back one year"
    echo "  -h, --help        Show this help message"
}

# Main function
main() {
    local args_output
    args_output=$(parse_args "$@")
    local -a args_array
    local old_ifs="$IFS"
    IFS='/' read -r -a args_array <<< "$args_output"
    IFS="$old_ifs"

    local github_username="${args_array[0]}"
    local word="${args_array[1]}"
    local num_commits="${args_array[2]}"
    local year="${args_array[3]}"

    # Validate word length and characters
    if [[ ${#word} -gt 8 ]]; then
        echo "Error: Word must be 8 characters or less"
        exit 1
    fi

    # Convert to uppercase and validate characters
    word=$(echo "$word" | tr '[:lower:]' '[:upper:]')
    if [[ ! "$word" =~ ^[A-Z0-9\ ]+$ ]]; then
        echo "Error: Word can only contain letters A-Z, numbers 0-9, and spaces"
        exit 1
    fi

    echo "Creating word art for '$word' on GitHub user '$github_username'"
    echo "Using $num_commits commits per active day, target year: $year"

    # Calculate dates based on year parameter
    local current_year
    current_year=$(date +%Y)
    local start_date
    local end_date

    if [[ "$year" -lt "$current_year" ]]; then
        # Past year: January 1 to December 31 of that year
        start_date="$year-01-01"
        end_date="$year-12-31"
        echo "Using past year mode: $start_date to $end_date"
    else
        # Current year: from today back one year
        end_date=$(date +%Y-%m-%d)
        start_date=$(get_date_n_days_ago 365)
        echo "Using current year mode: $start_date to $end_date"
    fi

    echo "Date range: $start_date to $end_date"

    # Find the first Sunday on or after start_date
    local chart_start_date="$start_date"
    local day_of_week
    day_of_week=$(get_day_of_week "$start_date")
    if [[ "$day_of_week" -ne 0 ]]; then
        local days_to_add=$((7 - day_of_week))
        chart_start_date=$(get_date_offset "$start_date" "$days_to_add")
    fi

    echo "Chart starts on: $chart_start_date (Sunday)"

    # Create the wordart repository with year suffix
    local repo_name="wordart-$year"
    echo "Creating repository '$repo_name'..."

    # Remove existing repo if it exists
    if [[ -d "$repo_name" ]]; then
        echo "Removing existing '$repo_name' directory..."
        rm -rf "$repo_name"
    fi

    # Create new repo
    mkdir "$repo_name"
    cd "$repo_name"
    git init --quiet

    # Create initial README
    echo "# Word Art: $word" > README.md
    echo "Generated word art for GitHub contribution chart" >> README.md
    git add README.md
    git commit -m "Initial commit" --quiet --no-gpg-sign

    # Create the word art
    local current_col=2  # Start with some padding


    for ((i=0; i<${#word}; i++)); do
        local char="${word:$i:1}"
        echo "Rendering character '$char' at column $current_col..."
        render_character "$char" "$current_col" "$chart_start_date" "$num_commits"
        current_col=$((current_col + 6))  # 5 for character + 1 for spacing
    done

    echo "Word art rendering completed!"

    # Create or update GitHub repository
    echo "Creating GitHub repository..."
    if gh repo create "$repo_name" --public --source=. --remote=origin --push; then
        echo "Word art creation completed!"
    else
        echo "Repository already exists. Updating with new word art..."
        # Add remote if it doesn't exist
        if ! git remote get-url origin >/dev/null 2>&1; then
            git remote add origin "https://github.com/$github_username/$repo_name.git"
        fi
        # Force push to overwrite existing commits
        echo "Force pushing new word art to existing repository..."
        git push --force-with-lease origin main 2>/dev/null || git push --force origin main
        echo "Word art creation completed!"
    fi

    echo "Repository URL: https://github.com/$github_username/$repo_name"
    echo "Visit your GitHub profile to see the word art on your contribution chart."

    cd ..
}

# Check dependencies
check_dependencies() {
    local missing_deps=()

    if ! command -v git >/dev/null 2>&1; then
        missing_deps+=("git")
    fi

    if ! command -v gh >/dev/null 2>&1; then
        missing_deps+=("gh (GitHub CLI)")
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo "Error: Missing dependencies:"
        printf ' - %s\n' "${missing_deps[@]}"
        echo ""
        echo "Please install the missing dependencies and try again."
        exit 1
    fi
}

# Run dependency check
check_dependencies

# Check for help flag first
for arg in "$@"; do
    if [[ "$arg" == "--help" || "$arg" == "-h" ]]; then
        show_usage
        exit 0
    fi
done

# Run main function with arguments
main "$@"
