tableextension 50006 "Sales Invoice Header Ext." extends "Sales Invoice Header"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "ShipStation Order ID"; Text[20])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'ShipStation Order ID', RUS = 'Идентификатор Заказа ShipStation ';
            Editable = false;
        }
        field(50001; "ShipStation Order Key"; Text[50])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'ShipStation Order Key', RUS = 'Ключ Заказа ShipStation';
            Editable = false;
        }
        field(50002; "ShipStation Order Status"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "Not Sent",Sent,Received;
            OptionCaptionML = ENU = 'Not Sent,Sent,Received', RUS = 'Не отправлен,Отправлен,Получен';
            CaptionML = ENU = 'ShipStation Order Status', RUS = 'Статус Заказа ShipStation';
            Editable = false;
        }
        field(50003; "ShipStation Status"; Text[50])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'ShipStation Status', RUS = 'Статус ShipStation';
            Editable = false;
        }
        field(50004; "ShipStation Shipment Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'ShipStation Shipment Cost', RUS = 'Сума отгрузки ShipStation';
            Editable = false;
        }
        field(50005; "ShipStation Insurance Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'ShipStation Insurance Cost', RUS = 'Сума страховки ShipStation';
            Editable = false;
        }
        field(50006; "ShipStation Shipment ID"; Text[30])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'ShipStation Shipment ID', RUS = 'ID Отгрузки ShipStation';
            Editable = false;
        }
        field(50007; "ShipStation Shipment Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'ShipStation Shipment Amount', RUS = 'Сума отгрузки ShipStation';
        }
        field(50008; "IC Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'IC Document No.', RUS = 'МФ Документ Но.';
        }
    }

    keys
    {
        key(SK1; "ShipStation Order ID", "ShipStation Order Key", "ShipStation Order Status", "ShipStation Status")
        {

        }
    }

    procedure GetShippingAgentName(ShippingAgentCode: Code[10]): Text[50]
    var
        _SA: Record "Shipping Agent";
    begin
        if _SA.Get(ShippingAgentCode) then
            exit(_SA.Name)
        else
            exit('')
    end;

    procedure GetShippingAgentServiceDescription(ShippingAgentCode: Code[10]; ShippingAgentServiceCode: Code[10]): Text[100]
    var
        _SAS: Record "Shipping Agent Services";
    begin
        if _SAS.Get(ShippingAgentCode, ShippingAgentServiceCode) then
            exit(_SAS.Description)
        else
            exit('')
    end;
}