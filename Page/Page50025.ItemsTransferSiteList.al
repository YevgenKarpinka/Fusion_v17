page 50025 "Items Transfer Site List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Item Transfer Site";
    Editable = false;
    CaptionML = ENU = 'Items Transfer Site List',
                RUS = 'Items Transfer Site List';

    layout
    {
        area(Content)
        {
            repeater(ItemsTransferSite)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}