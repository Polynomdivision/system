import sys
import yaml

def main():
    if not len(sys.argv) > 1:
        print("ERROR: Not enough arguments")
        return

    for f in sys.argv[1:]:
        try:
            yaml.load(open(f).read())
        except:
            print("'%s' failed to be loaded by PyYaml" % f)
            continue

if __name__ == "__main__":
    main()
