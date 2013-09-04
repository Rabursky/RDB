KULE Example

To use this example you need to setup mongoDB with new collection by typing in mongo console:

use example
db.createCollection("tasks")

Thats it, mongo set up.
Now you have to run kule (if you havent installed it yet, just type "easy_install kule") using this command:
python -m kule --database example --collections tasks

After this steps, you are fully set up to use thsi example. Easy, huh? :)
