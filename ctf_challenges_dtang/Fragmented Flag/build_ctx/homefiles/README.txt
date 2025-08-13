[ Challenge 2 ]
Your home folder has many .txt files.
Some lines look like {fragmentN:X}.
Sort N from 1..10 and join the X characters to get the flag.

Try:
  grep -R "{fragment" .
  # or one-liner:
  awk '{ if (match($0, /\{fragment([0-9]+):([^}]+)\}/, m)) print m[1], m[2] }' *.txt | sort -n | awk '{print $2}' | tr -d "\n"
