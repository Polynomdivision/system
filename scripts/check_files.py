import sys
import yaml
import os

def should_skip(src, ignore_list, print_msg=True):
    for ignore in ignore_list:
        if ignore in src:
            if print_msg:
                print("Skipping '%s' because of the following occurance:" % src)
                print("'%s'" % ignore)

            return True
    return False

def main():
    # Args
    if not len(sys.argv) > 1:
        print("ERROR: Not enough arguments")
        return

    dbg = False
    print_ignore = False
    ignore_list = []

    for arg in sys.argv[1:]:
        # Debug? 
        if arg == "--debug":
            dbg = True
            continue
        
        if arg == "--print-ignore":
            print_ignore = True
            continue

        if "--ignore-var=" in arg:
            ignore_element = arg.split("=")[1]
            ignore_list.append(ignore_element)
            if dbg: print("I: Added '%s' to the ignore list" % ignore_element)
            continue

        f = arg

        cont = open(f).read()
        try:
            yml = yaml.load(cont)
        except err:
            print("ERROR: '%s' contains invalid YAML" % f)
            print("Skipping...")
            continue

        if yml == None: continue

        for task in yml:
            # {'name': ..., '...': ...}
            if not hasattr(task, "keys"): continue

            for task_key in task.keys():
                # -> 'name', 'pacman', ...
                if task_key == "copy":
                    copy_task = task["copy"]
                    role_path = os.getcwd() + "/roles/" + f.split("/")[2] 
                    src = copy_task["src"].replace("{{ role_path }}", role_path)

                    if "{{ item }}" in src:
                        # Check the source
                        for item in task["with_items"]:
                            path = src.replace("{{ item }}", item)
                            
                            if should_skip(path, ignore_list, print_ignore): continue

                            if not os.path.exists(path):
                                if dbg: print("dbg: Checked '%s'" % path)
                                print("f: %s" % f)
                                print("'%s' does not exist" % item)
                                print("------------------")
                    else:
                        if should_skip(src, ignore_list, print_ignore): continue

                        if not os.path.exists(src):
                            if dbg: print("dbg: Checked '%s'" % src)
                            print("f: %s" % f)
                            print("'%s' does not exist" % src)
                            print("------------------")
                    

if __name__ == "__main__":
    main()
