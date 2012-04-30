#!/usr/bin/env python
import sys
import os.path
import csv
import json
import urllib2

""" convert a DirectGov mapping GoogleDoc into Migratorator JSON
"""

def parse_section_name(name):
    # TODO: parse out section name from our file name
    bits = name.split('-')
    return urllib2.unquote(bits[1])

if len(sys.argv) < 2:
    sys.stderr.write("usage: " + os.path.basename(sys.argv[0]) + " filename\n")
    sys.exit(1)

in_f = sys.argv[1]

f = csv.reader(open(in_f, 'rb'))

""" header[gov title,
            URL,
            content type,
            y/n,
            why not,
            notes,
            editor notes,
            redirect URL,
            search phrase,
            ext URL,
            map status,
            editor notes,
            del tem,
            completed]
"""

ignore_headers = ["", "directgov title", "example title"]
rep = []
section = parse_section_name(in_f)

for row in f:
    try:
        row[0].lower() in ignore_headers
    except IndexError, e:
        continue

    if row[0] != "":
        if len(row) < 3:
            print 'problematic row: EMPTY: ', row
            continue

        tags = []
        tags.append("section:%s" % section)
        tags.append(row[2])

        data = {
            'title': row[0],
            'old_url': row[1],
            'tags': tags,
        }

        # article and content types *should* have further info
        if row[2].lower() != 'nav':
            try:
                if row[3].lower() in ["y", "n"]:
                    data['needs_met'] = True
                    if row[3].lower() == "n":
                        data['needs_met'] = False

                data['notes'] = '%s \n\n %s' % (row[4], row[5])
            except IndexError:
                print >> sys.stderr, 'Problematic row: MISSING some info: ', row
                continue

            try:
                if row[7] != "":
                    data['new_url'] = row[7]
                    data['status'] = '301'
                else:
                    data['status'] = '410'
            except IndexError:
                data['status'] = '404'

            try:
                if row[8] != "":
                    data['search'] = row[8]
                if row[9] != "":
                    data['see_also'] = [('', row[9])]
            except IndexError:
                pass

        rep.append(data)
    else:
        print >> sys.stderr, 'Problematic row: ', row

sys.stdout.write(json.dumps({'mappings': rep}))
