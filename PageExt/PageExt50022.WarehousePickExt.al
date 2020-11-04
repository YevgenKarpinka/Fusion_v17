pageextension 50022 "Warehouse Pick Ext." extends "Warehouse Pick"
{
    layout
    {
        // Add changes to page layout here
        addbefore("No.")
        {
            field(CustomerName; ShipStationMgt.GetCustomerNameFromWhsePick(Rec."No."))
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Customer Name',
                            RUS = 'Имя клиента';
                toolTipML = ENU = 'Specifies customer name the warehouse pick document.',
                            RUS = 'Определяет имя клиента документа складского подбора.';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        ShipStationMgt: Codeunit "ShipStation Mgt.";
}