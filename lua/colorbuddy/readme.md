# Interfaces

Color
Group
Style

Mixed


```
Required:

Fields:
    self.children
    self.parents
Functions:
    self:update({updated})
        Arguments:
            {updated}: Hash of objects we've already updated

        Process:
            1. Wait for parents to complete
            2. Update self
            3. Add self to {updated}
            4. Tell children to update

    self:apply()
```
