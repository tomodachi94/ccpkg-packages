--BulkCopy  by Tomodachi94
--(c) 2020 by Tomodachi94, under the Apache 2.0 license.
--These comments denoting copyright must remain here by international copyright law. Please leave them.
--Last revised by Tomodachi94 on 12/13/2020. (CONTRIBUTORS: CHANGE THIS WHEN YOU EDIT)

while true do

fullPath = "disk/file" --
diskSide = "right"
labelToSet = "label"

sleep(1)
term.clear()
term.setCursorPos(1, 1)

print("---------------------------")
print("BulkCopy by Tomodachi94")
print("(c) 2020 Apache License")
print("tomodachi94.github.io/utils")
print("---------------------------")
print("Waiting for disk...")
if disk.isPresent(diskSide) then
  print("Disk found!")
  if fs.exists(fullPath) then
    print("Duplicate file on the disk has been detected. Removing...")
    shell.run("rm", fullPath)
  end

if disk.hasLabel(diskSide)
  print("Why does this disk have a label? Ejecting...")
print("Copying 'payload' to", fullPath)
shell.run("cp payload", fullPath)
print("Setting label to '", labelToSet, "'")
shell.run("label set", diskSide, labelToSet)
disk.eject(diskSide)
end
end
