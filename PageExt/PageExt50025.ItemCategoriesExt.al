pageextension 50025 "Item Categories Ext" extends "Item Categories"
{
    layout
    {
        // Add changes to page layout here
        addlast(Control1)
        {
            field("Description RU"; "Description RU")
            {
                ApplicationArea = All;
                Importance = Additional;
            }
        }
    }
}