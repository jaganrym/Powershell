# Creating Files and Folders
new-item -path 'C:\PshoutPut' -ItemType Directory
new-item -path 'C:\PshoutPut\Testfile.txt' -ItemType file
# Copying Files
copy-item 'C:\pshoutput\testfile.txt' 'C:\PshoutPut1'
# Copy all txt files under C:\psoutput to 'C:\PshoutPut1' recursivesly
copy-item -filter *.txt -path 'C:\PshoutPut' -Recurse -Destination 'C:\PshoutPut1'
#Move Files
move-item 'C:\pshoutput\testfile.txt' 'C:\PshoutPut1'