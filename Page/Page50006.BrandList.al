page 50006 "Brand List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Brand;
    AccessByPermission = tabledata Brand = rimd;

    layout
    {
        area(Content)
        {
            repeater(RepeaterName)
            {
                Editable = false;
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;

                }
                field("Manufacturer Code"; Rec."Manufacturer Code")
                {
                    ApplicationArea = All;

                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;

                }
                field("Name RU"; Rec."Name RU")
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    actions
    {

    }
}