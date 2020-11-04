pageextension 50000 "Manufacturers Ext." extends Manufacturers
{
    layout
    {
        // Add changes to page layout here
        addlast(Control1)
        {
            field("Name RU"; Rec."Name RU")
            {
                ApplicationArea = All;
                Importance = Additional;
            }
            field(Address; Rec.Address)
            {
                ApplicationArea = All;
                Importance = Additional;
            }
        }
    }
}
