tableextension 50005 "Shipping Agent Services Ext." extends "Shipping Agent Services"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "SS Carrier Code"; Text[20])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'ShipStation Carrier Code', RUS = 'ShipStation курьер код';
            Editable = false;
        }
        field(50001; "SS Code"; Text[50])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'ShipStation Code', RUS = 'ShipStation код';
            Editable = false;
        }
        field(50002; "Shipment Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Shipment Cost', RUS = 'Стоимость доставки';
            Editable = false;
        }
        field(50003; "Other Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Other Cost', RUS = 'Иная стоимость';
            Editable = false;
        }
    }

    keys
    {
        key(SK1; "SS Carrier Code", "SS Code")
        {

        }
    }
    procedure InsertServicesFromShipStation(CarrierCode: Code[10]; ServiceCode: Code[10]; SS_CarrierCode: Text[20]; SS_ServiceCode: Text[50]; SS_ServiceName: Text[100])
    begin
        Init();
        "Shipping Agent Code" := CarrierCode;
        Code := ServiceCode;
        Insert();
        "SS Carrier Code" := SS_CarrierCode;
        "SS Code" := SS_ServiceCode;
        Description := SS_ServiceName;
        Modify();
    end;

    procedure TempInsertServicesFromShipStation(var _SAS: Record "Shipping Agent Services" temporary; CarrierCode: Code[10]; ServiceCode: Code[10]; SS_CarrierCode: Text[20]; SS_ServiceCode: Text[50]; SS_ServiceName: Text[100])
    begin
        _SAS.Init();
        _SAS."Shipping Agent Code" := CarrierCode;
        _SAS.Code := ServiceCode;
        _SAS.Insert();
        _SAS."SS Carrier Code" := SS_CarrierCode;
        _SAS."SS Code" := SS_ServiceCode;
        _SAS.Description := SS_ServiceName;
        _SAS.Modify();
    end;
}