import mdl

def run(filename):
    """
    This function runs an mdl script
    """
    p = mdl.parseFile(filename)

    if p:
        f = open('__COMPYLED_CODE__', 'w')
        f.write(str(p))
        f.close()
    else:
        print "Parsing failed."
        return
