import crypt
import uuid
import getpass

def main():
    entry1 = getpass.getpass(prompt="Enter password: ")
    entry2 = getpass.getpass(prompt="Re-enter password: ")

    print(crypt.crypt(entry1, "$6$%s$" % uuid.uuid4().hex) if entry1 == entry2 else "PASSWORDS DON'T MATCH")

if __name__ == '__main__':
    main()
