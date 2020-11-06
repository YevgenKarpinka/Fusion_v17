pageextension 50021 "Item Category Card Ext." extends "Item Category Card"
{
    layout
    {
        // Add changes to page layout here
        addlast(General)
        {
            field("Description RU"; "Description RU")
            {
                ApplicationArea = All;
                Importance = Additional;
            }
        }
    }
}
