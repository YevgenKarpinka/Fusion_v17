pageextension 50000 "Manufacturers Ext." extends Manufacturers
{
    layout
    {
        // Add changes to page layout here
        addlast(Control1)
        {
            field("Name RU"; "Name RU")
            {
                ApplicationArea = All;
                Importance = Additional;
            }
            field(Address; Address)
            {
                ApplicationArea = All;
                Importance = Additional;
            }
        }
    }
}
