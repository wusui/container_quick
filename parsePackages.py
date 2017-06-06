from HTMLParser import HTMLParser
"""
Simple parser to extract field names from url data
"""

def gen_parse(html_file, parser):
    """
    html_file: Local file containing url data (extracted via a wget)
    parser: HTMLParser object (defined below)
    """
    with open(html_file, 'r') as f:
        contnt = f.read()
    parser.feed(contnt)
    return parser

class Parser(HTMLParser, object):
    """
    After parsing, self.odata will contain the name of the rpm that we are
    looking for. 
    """
    def __init__(self, parm1):
        """
        parm1 is the start of the file whose name we want to find.
        """
        self.odata = ''
        self.scan_for = parm1
        super(Parser, self).__init__()
    def handle_starttag(self, tag, attrs):
        for attr in attrs:
            if attr[0] == 'href':
                if attr[1].startswith(self.scan_for):
                    self.odata = attr[1]
    def get_result(self):
        return self.odata

import sys
if __name__ == "__main__":
    """
    Find an rpm and print it's name
    """
    if len(sys.argv) != 3:
        print "Usage python parsePackages <url-data> <name-of-file>"
        exit(-1)
    urldata = gen_parse(sys.argv[1], Parser(sys.argv[2]))
    print urldata.get_result()

