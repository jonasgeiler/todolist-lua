# todolist-lua
A simple todolist for the command line written in Lua.

This is a rework of a very old project of mine, which was actually one of the
first projects I ever uploaded to GitHub!  
If you want to see the old version, check out the 
[`old-version`](https://github.com/skayo/todolist-lua/tree/old-version)
tag.  
But be warned of the bad code :D

> [!NOTE]  
> Since this is just a little experiment, I won't go into too much detail about
> how it works, how to use it, or what exactly it does. Feel free to 
> [start a new discussion](https://github.com/skayo/todolist-lua/discussions)
> if you have any questions!

## Requirements
- LuaJIT 2.1 or Lua 5.1 (newer versions might work but not tested)

## Usage
```bash
$ luarocks install

$ ./todo list ./todolist.md
1. [X] Start reworking todolist-lua
2. [ ] Finish reworking todolist-lua
3. [ ] Write documentation
4. [ ] Write tests
```

## About Todofiles
The todofiles that this CLI creates and manages are basically just Markdown files and can be viewed in any Markdown editor (needs GitHub-flavored Markdown support for showing checkboxes).
This makes them easy to view on GitHub and also more manageable with git.
Here's what a todofile looks like:
```markdown
1. [X] Todo 1
2. [ ] Todo 2
3. [X] Todo 3
4. [ ] Todo 4
```
As you can see it's just an ordered list of checkboxes with text.

> [!WARNING]
> I have not added support for any content in the todofile other than the actual list of todos - any additional headings or paragraphs will be overwritten or appended to the previous todo item!
