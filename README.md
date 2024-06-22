# Console-based search utility

This is a command-line search tool that allows you to search for files containing a specific keyword in a given set of directories.

It also allows you to

- Search for a file or folder in a set of directories (that can be the whole disk if needed);
- Refine the initial search query results with new keywords;
- Copy a select folder or file's path to clipboard;
- Open a new console (cmd) in the selected folder or file's directory in a new window;
- Open a selected folder or file itself with the default software as set in the OS;
- Open a select folder or file's location in Explorer;
- Delete a selected file;
   - Deletion for folders not implemented yet, but it will delete files inside the folder;
- Open a selected folder or file in vscode;
- Open a selected folder or file's directory in vscode;
- Open a selected folder or file in vim;
- Move the selected file or folder to new custom or predefined location;
- Rename a selected file;

Everything is done easily from the keyboard in the console interface, with not much typing.

**You can add new routines that might suit your personal needs**. Just follow the same pattern: create a new routine like the existing ones, add it to the `:chooseFile` loop and assign a "suffix" to activate it.

You just need to **make sure** the "suffix"" and its assigment logic does not conflict with the existing ones anyhow.

## Motivation

Windows search sucks. If you open explorer and narrow down in some folders, it can suck less than it would, but it's not optimal. In addition to that, handling files when inside the "search mode" is even worse.

I used to have a software to help me with that when I was in my master's. I had to iterate and search for piles of `pdfs`, so I really needed a more robust thing. After I formatted my PC in the past year, I lost it. I don't even remember its name. Searched a bit for it in the internet but I could not found the forgotten unnamed app.

This script is my solution for repetitive searches and my own impatience with Explorer. I even wish I could send it back in time to my struggling master's student self.

To my today's self, it's more of a facilitator to search for, modify and interact with a set of files in my pc (mostly python scripts, hence the usage of `vscode`). It's a simple script, there are probably best solutions out there, but it fits my need and served as a small bit of study and practice in batch scripting.

## Inner workings

- The search algorithm in a simple linear search with wildcard matching.
- It iterates over each directory and its subdirectories recursively, checking if any folder or files match the keywords.
- The algorithm will iterate only over the paths declared in `search_paths.txt`. Just write any paths following the pattern already present there. **Don't** leave `\` at the end of the paths and separate them by a single line break.
   - This method was chosen so that the user can limit the scope of the search, requiring less processing power and time over the iterations, making it more efficient for repetitive usage.
   - You can, however, add a whole disk simply writing `C:`.
   - Tip: Place this directory in the search path, so you can quickly find and modify the `search_paths.txt` to add or remove another one.
- The refined search will search inside the list created in the previous search.
- You can look by file extensions by querying for ".csv" or ".py", for example, in the initial or the refined search.
- For the `move` command, the script will look into the list of predefined paths inside `move_paths.txt` and ask the user for an input. The user can input manually any path he or she would like or, alternatively, the user can just type one of the numbers associated with the predefined path wanted.
   - **Don't** leave `\` at the end of the paths and separate them by a single line break.
   - When manually typing a path, you can use the auto-complete feature by pressing the `tab` key.

## Usage

1. Run the `run_search.bat` file.
2. Enter the search keyword when prompted.
3. The tool will search for files containing the keyword in the specified directories.
4. The search results will be displayed like a vertical list, showing the file paths associated with a number.
5. Choose one of the options that will be prompted
   - Enter the number of the file to open it with the OS's default software
   - You can also add suffixes that will call commands and routines defined inside the script.
   - So if you want to open the file indexed as `7` in `vim`, write the file number + vim, like:
   ```
   7vim.
   ```
   - The same for other options. Write them right after the number, with no spaces or enters. So, if instead of opening in vim you'd prefer to copy the selected path to clipboard, you' write the `7c` or, if you'd like to open a new console window in the selected file's directory, you'd type `7cd`. All the options are listed below.

   - These options will be prompted on the console when running the script. You can also check them inside the script code.

6. To go back and make another search, write `b` or `<space><enter>`

7. To refine the search with new keywords, write `<space><space><enter>` or `ref` without any numbers

8. Currently, the script handles the following actions
   - `<number>vim` to open a file with vim;
   - `<number>c` to copy the file path to clipboard;
   - `<number>del` to delete a file;
   - `<number>code` to open a file with VsCode;
   - `<number>cdir` to open a file directory in VsCode;
   - `<number>cd` to open a new console window in the selected file's directory location;
   - `<number>exp` to open in explorer;
   - `<number>move` to move the selection to a new custom location to be typed or to one of the predefined locations;
   - `<number>ren` to open a prompt to rename the selected file;

## Configuration

The search paths are defined in the `search_paths.txt` file. Each path should be on a separate line, as in the example.

The `move_paths.txt` file is used to store a predefined list of paths that can be used with the `move` command. This file allows you to define paths that are frequently used, making it easier to select them when executing the standard `move` command. You can also manually type any path directly in the command.

### Make your own "commands"" and routines

You can modify the "suffixes" in this script. I just made what makes sense for me. You can also add new routines and assign a new suffix.

To modify any keywords, to go to `:chooseFile` routine inside the script and search for the routine you want to change the "suffix".

For example:

```batch
else if "!fileChoice:~-4!"=="code" (
    set /a fileIndex=!fileChoice:~0,-4!
    call :openWithVSCode !fileIndex!
    goto chooseFile
)
```

This snippet says that if "code" is in the last four letters (i.e., it's the suffix) of a choice, then it must pass the path associated with the selected number to the selected routine (in this case, `:openWithVSCode`).

As "code" has only 4 letters, I need to make sure it checks the last 4 letters of a choice (that's why `"!fileChoice:~-4`) and I need to pass the choice -4 letters, so it keeps only the number of the index of the path (that's why `set /a fileIndex=!fileChoice:~0,-4!`).

You can also add new routines at the end of the script. Just follow the pattern of adding it as option in the `:chooseFile` and call it from there.

## To-dos

1. Allow users to specify file extensions to search for (it can already be done by refining the search).
2. Facilitate the change of "suffixes" and the addition of new routines.
