---
description: createNewRepositoryFromTemplate
mode: agent
---

1. Use git commands to
   determine the actual project name and repository location:
   ```bash
   git remote -v
   ```

2. Read all files in the project. Understand project struct.
   Use avaiable scripts in project or any other command line tools lookings for:

   1. TODOs
   2. Strings that need to be replaced, such asi
      "template", "YOUR NAME", and other obvious placeholder text.

3. You should replace those stirngs with the actual project name.

4. Recheck check TODOs in the project to
   ensure you have completed all TODOs related to the project name.
