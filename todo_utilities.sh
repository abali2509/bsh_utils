


# tput setaf 1 = red, 2 = green, 3 = yellow, 4 = blue, 5 = magenta, 6 = cyan, 7 = white
# functions to create, read, update, and delete todo items

# add a -h help flag to display usage information
display_usage() {
    tput setaf 6; echo "\n\tTodo - A simple todo list manager\n"
    echo "\tUsage: todo [flag]"
    echo "\t********************************************"
    echo "\tNo flag will create a new todo list with the\n\tcurrent date or append to existing todo list"
    echo "\t********************************************"
    echo "\tFlags:"
    echo "\t-l\tList all todo items"
    echo "\t-u\tUpdate a todo item"
    echo "\t-d\tDelete a todo item"
    echo "\t-m\tMark a todo item as done"
    echo "\t-a\tAppend a todo item to the list"
    echo "\t-h\tDisplay usage information\n"
}


# check is todo directory exists in home and if it doesn't create it
check_todo_dir() {
    if [ ! -d ~/todo ]; then
        mkdir ~/todo
    fi
}

# create a todo file if it doesn't exist with the date as the name
create_todo_file() {
    if [ ! -f ~/todo/$(date +%F).txt ]; then
        touch ~/todo/$(date +%F).txt
        echo "\t Todo list date: $(date +%F) \n" >> ~/todo/$(date +%F).txt
        nvim +2 ~/todo/$(date +%F).txt
    else 
        nvim ~/todo/$(date +%F).txt
    fi
}



# update a todo file with a new item
update_todo_file() {
    # check is todo directory exists in home and if it doesn't create it
    check_todo_dir
    # check if todo file exists for the current date and if it doesn't create it
    if [ ! -f ~/todo/$(date +%F).txt ]; then
        touch ~/todo/$(date +%F).txt
        echo "\t Todo list date: $(date +%F) \n" >> ~/todo/$(date +%F).txt
    
    # check if todo file is empty
    elif [ ! -s ~/todo/$(date +%F).txt ]; then
            echo "\tTodo list is empty\n"
            exit 1
    
    # file is not empty
    else
        # set text color to magenta
        tput setaf 5; echo "\tUpdating todo file $(date +%F).txt\n"
        # cat current todo file with line numbers
        awk '{if (NR >= 2) {count++; print count, $0}}' ~/todo/$(date +%F).txt | sed -e 's/^/\t/' -e 's/:/  /'
        # prompt user for line number to update
        echo -n "\tEnter the item to update: "
        read line_number
        # prompt user for new item
        clear
        echo "\tCurrent item to update:\n"
        awk -v line_number="$line_number" '{if (NR == line_number + 1) {print $0}}' \
        ~/todo/$(date +%F).txt | sed -e 's/^/\t/' -e 's/:/  /'
        echo -n "\n\tEnter the new item: "
        read new_item
        clear
        # update the todo file with the new item
        awk -v new_item="$new_item" -v line_number="$line_number" '{if (NR == line_number + 1) {print new_item} else {print $0}}' \
        ~/todo/$(date +%F).txt > ~/todo/$(date +%F).txt.tmp && mv ~/todo/$(date +%F).txt.tmp ~/todo/$(date +%F).txt
        # display updated todo file
        echo "\tUpdated todo list $(date +%F) file\n"
        awk '{if (NR >= 2) {count++; print count, $0}}' ~/todo/$(date +%F).txt | sed -e 's/^/\t/' -e 's/:/  /'
        echo "\n"
        sleep 2 
        clear
    fi
    
}

# delete item from todo file

delete_todo_item() {
    tput setaf 1; echo "\tDeleting todo item from $(date +%F).txt\n"
    # cat current todo file with line numbers
    awk '{if (NR >= 2) {count++; print count, $0}}' ~/todo/$(date +%F).txt | sed -e 's/^/\t/' -e 's/:/  /'
    # prompt user for line number to delete
    echo -n "\n\tEnter the item to delete: "
    read line_number
    # increment line number by 1 to match the line number in the file
    line_number=$((line_number + 1))
    # delete the item from the todo file
    sed -i "${line_number}d" ~/todo/$(date +%F).txt
    # display updated todo file
    echo "\n\tUpdated todo $(date +%F).txt file\n"
    awk '{if (NR >= 2) {count++; print count, $0}}' ~/todo/$(date +%F).txt | sed -e 's/^/\t/' -e 's/:/  /'
    sleep 2 
    clear
}

# mark item as done in todo file / add - DONE at the end of the line

mark_todo_item_done() {
    tput setaf 2; echo "\tMarking todo item as done in $(date +%F).txt\n"
    # cat current todo file with line numbers
    awk '{if (NR >= 2) {count++; print count, $0}}' ~/todo/$(date +%F).txt | sed -e 's/^/\t/' -e 's/:/  /'
    # prompt user for line number to mark as done
    echo -n "\n\tEnter the item to mark as done: "
    read line_number
    # increment line number by 1 to match the line number in the file
    line_number=$((line_number + 1))
    # mark the item as done in the todo file
    sed -i "${line_number}s/$/ - DONE/" ~/todo/$(date +%F).txt
    # display updated todo file
    echo "\n\tUpdated todo $(date +%F).txt file\n"
    awk '{if (NR >= 2) {count++; print count, $0}}' ~/todo/$(date +%F).txt | sed -e 's/^/\t/' -e 's/:/  /'
    sleep 2 
    clear
}

# append item todo list in todo file

append_todo_item() {
    tput setaf 3; echo "\tAppending todo item to $(date +%F).txt\n"
    # cat current todo file with line numbers
    awk '{if (NR >= 2) {count++; print count, $0}}' ~/todo/$(date +%F).txt | sed -e 's/^/\t/' -e 's/:/  /'
    # prompt user for new item
    echo -n "\n\tEnter the new item: "
    read new_item
    # append the new item to the todo file
    echo $new_item >> ~/todo/$(date +%F).txt
    # display updated todo file
    echo "\n\tUpdated todo $(date +%F).txt file\n"
    awk '{if (NR >= 2) {count++; print count, $0}}' ~/todo/$(date +%F).txt | sed -e 's/^/\t/' -e 's/:/  /'
}

# list all items in todo file/ split and list items that have been marked as done

list_todo_items() {
    tput setaf 4; echo "\tListing todo items in $(date +%F).txt\n"
    # cat current todo file with line numbers (skip first line of file) where item isnt marked as done
    echo "\n\tItems yet to be completed\n"
    awk '!/DONE/ {if (NR >= 2) {count++; print count, $0}}' ~/todo/$(date +%F).txt | sed -e 's/^/\t/' -e 's/:/  /'
    # grep -nv 'DONE' ~/todo/$(date +%F).txt | sed -e 's/^/\t/' -e 's/:/  /'

    # display items that have been marked as done
    echo "\n\tItems marked as done\n"
    awk '/DONE/ {if (NR >= 2) {count++; print count, $0}}' ~/todo/$(date +%F).txt | sed -e 's/^/\t/' -e 's/:/  /'
    
}

# Add your code here to handle the case when no flags are passed
if [ -z "$1" ]; then

  # check if todo directory exists in home and if it doesn't create it
  check_todo_dir

  # create a new todo file if it doesn't exist with the date as the name
  create_todo_file

  # declare exit status as 0 to indicate success
  exit 0
else

  # loop through the flags and handle each one
  while [ ! -z "$1" ]; do
    case "$1" in
      -u)
        update_todo_file
        ;;
      -d)
        delete_todo_item
        ;;
      -m)
        mark_todo_item_done
        ;;
      -a)
        append_todo_item
        ;;
      -l)
        list_todo_items
        ;;
      -h)
        display_usage
        ;;
      *)
        echo "Flag $1 is not recognized"
        exit 1
        ;;
      --)
        shift
        break
        ;;
    esac
    shift
  done
fi
