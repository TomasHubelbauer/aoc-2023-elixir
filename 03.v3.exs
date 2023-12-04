# TODO:
# - Parse the file line by line starting with two lines
# - Use `Regex.scan/3` to extract the serial numbers for each new line
# - Check that each line has the same length as the prior line
# - Find overlaps between the origin of each symbol and the serials
# - Drop serials as they go out of scope of the three line window
#
# This way we can process the file using a constantish small amount of memory
