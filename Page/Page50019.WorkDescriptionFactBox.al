page 50019 "Work Description FactBox"
{
    PageType = CardPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = History;
    SourceTable = "Sales Header";
    CaptionML = ENU = 'Work Description', RUS = 'Описание работы';
    AccessByPermission = tabledata "Sales Header" = r;
    Editable = false;

    layout
    {
        area(Content)
        {
            field(WorkDescription; Rec.GetWorkDescription())
            {
                ApplicationArea = All;
                ShowCaption = false;
            }
        }
    }
}