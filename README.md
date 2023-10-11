# Replace PDF Pages

## Prerequisites

Uses pdftk for PDF operations.

## Idea

![Scheme](scheme1.svg)

## Usage

Use this script with:

`pdfreplace fileA.pdf fileB.pdf output.pdf 1 2 10 12`

Where 
* filesA and fileB are input files 
* output.pdf - output file name
* following numbers are page numbers in fileA to be replaced with subsequent pages in fileB
