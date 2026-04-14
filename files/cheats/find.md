# find

#### list files and dirs, owner and permissions

```shell
find . -printf '%M %u:%g %p\n'
```

What you get (per file/dir):
- %M → permissions (e.g. drwxr-xr-x)
- %u:%g → owner:group
- %p → full path
    
---
