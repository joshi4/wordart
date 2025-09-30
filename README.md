# GitHub Word Art Generator

Creates commits on specific dates to spell words on GitHub's contribution chart.

## Requirements

- git
- GitHub CLI (gh)

## Usage

```bash
./gh-wordart.sh [OPTIONS] <github_username> <word>
```

### Arguments

- `github_username` - Your GitHub username
- `word` - Word to render (max 8 characters, A-Z, 0-9, spaces)

### Options

- `--num-commits N` - Number of commits per active day (default: 45)
- `--year YYYY` - Target year for the art (default: current year)
  - Past year: Jan 1 to Dec 31 of that year
  - Current year: From today back one year
- `-h, --help` - Show help message

## Examples

Create word art with default settings:
```bash
./gh-wordart.sh joshi4 HELLO
```

Create word art with custom commit count:
```bash
./gh-wordart.sh joshi4 SAVVY --num-commits 60
```

Create word art for a specific past year:
```bash
./gh-wordart.sh joshi4 HASKELL --year 2014
```

## How It Works

1. Creates a new repository named `wordart-<year>`
2. Generates commits with specific dates to form letter patterns
3. Each letter is 5 columns wide by 7 rows tall on the contribution chart
4. Pushes commits to GitHub to display on your contribution chart

## Notes

- Words are automatically converted to uppercase
* For the current year, `gh-wordart` starts from the same day 1 year ago as today (default chart view on GitHub)
- The script creates empty commits with custom dates
- Visit your GitHub profile after running to see the word art on your contribution chart

