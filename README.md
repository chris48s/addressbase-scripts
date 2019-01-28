# AddressBase Scripts

Messy python/SQL for working with AddressBase Premium.

TODO: tidy this up

```sh
# Use the script provided by OS to pre-process the AB Premium files for DB import
os$ ./AddressBasePremium_RecordSplitter.py

# Create a DB to import into
sudo -u postgres createdb addressbase_premium

# Copy connection file..
custom$ cp ./connection.example.py ./connection.py
# ..and fill in DB username and password

# Create table structure
custom$ ./create_tables.py

# Import the files and create keys/constratints
custom$ ./import.py /path/to/split_files

# Export geographic addresses for type C and L UPRNs to a CSV
custom$ ./make_csv.py

# Join with the output of clean_addressbase from uk-geo-utils
custom$ cat ./output.csv /path/to/addressbase_cleaned.csv > merged.csv
# this will give us a single file with
# postal addresses of Type D UPRNS from AddressBase Standard and
# geographic addresses for type C and L UPRNs from AddressBase premium
```
