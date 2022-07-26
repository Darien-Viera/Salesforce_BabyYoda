# script for parsing the planets csv into a multiline string ready to be
# run in an apex anonymous call to insert said planets into the DB
# the output string must resemble the next one:

# String planets = 'Name;External_id__c' +
# 'Alderaan;A-00001' +
# 'Aleen Minor;AM-00002' +
# 'Zolan;Z-00060';

from datetime import datetime


def parsePlanets():
    try:
        # open the file in read mode from the same directory as the script
        planetsFile = open("Planet__c.csv", "r")
    except OSError as ex:
        print("> could not open/read files " + str(ex))
        exit()
    with planetsFile:
        # with the file opened, prepare the required variables to iterate over the file
        print("> files opened successfully")
        lines = planetsFile.readlines()
        numberOfLines = len(lines)
        print("> numberOfLines = " + str(numberOfLines))
        lineNumber = 0
        planetsConcatenated = 'String planets = \''

        # iterate over the lines in the file to build the output string
        for line in lines:
            # remove blank spaces at both ends of the line
            line = line.strip()
            print("> " + str(lineNumber) + " line = " + line)
            # append the processed line with simple quote (\')
            planetsConcatenated += line
            # if the processed line is the last one, just append the semicolon (;)
            # if not append a linebreak and a semicolon for the next line
            if lineNumber == numberOfLines - 1:
                planetsConcatenated += '\';'
            else:
                planetsConcatenated += '\\n\' +\n\''
            lineNumber += 1

        # create a new file to save the output in case we need it later
        # the current date and time is being used for the name of the new file
        now = datetime.now()
        nowStr = str(now).replace(":", "")
        nowStr = nowStr.replace(".", "")
        nowStr = nowStr.replace("-", "")
        nowStr = nowStr.replace(" ", "")
        newFile = open(nowStr + ".txt", "x")
        newFile.write(planetsConcatenated)
        print(planetsConcatenated)


if __name__ == "__main__":
    print('\n> parsePlanetsIntoMultiline.py script running...')
    parsePlanets()
