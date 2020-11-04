table 50003 "Bank Check Journal Line"
{
    DataClassification = ToBeClassified;
    CaptionML = ENU = 'Source Parameters', RUS = 'Параметры подключения';

    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer;

            trigger OnValidate()
            begin
                if xRec."Customer No." = Rec."Customer No." then exit;
                "Source No." := '';
            end;
        }
        field(3; "Bank Check No."; Code[35])
        {
            DataClassification = CustomerContent;

        }
        field(4; "Bank Check Date"; Date)
        {
            DataClassification = CustomerContent;

        }
        field(5; Description; Text[100])
        {
            DataClassification = CustomerContent;

        }
        field(6; Amount; Decimal)
        {
            DataClassification = CustomerContent;

        }
        field(7; "Source Type"; Option)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Source Type', RUS = 'Тип Источника';
            OptionMembers = " ",SalesOrder,SalesInvoice;
            OptionCaptionML = ENU = ' ,SalesOrder,SalesInvoice', RUS = ' ,ЗаказПродажи,СчетПродажи';
        }
        field(8; "Source No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = IF ("Source Type" = CONST(SalesOrder)) "Sales Header"."No." WHERE("Document Type" = CONST(Order), "Sell-to Customer No." = field("Customer No.")) ELSE
            IF ("Source Type" = CONST(SalesInvoice)) "Sales Invoice Header"."No." WHERE("Sell-to Customer No." = field("Customer No."));
        }
        field(9; "Last Modified DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; Status; Option)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'Status', RUS = 'Статус';
            OptionMembers = New,Confirmed,Rejected;
            OptionCaptionML = ENU = 'New,Confirmed,Rejected', RUS = 'Новый,Подтвержденный,Отказаный';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "ID")
        {
            Clustered = true;
        }
        key(SK01; "Bank Check No.", "Bank Check Date") { }
    }

    trigger OnInsert()
    begin
        SetLastModifiedDateTime();
    end;

    trigger OnModify()
    begin
        SetLastModifiedDateTime();
    end;

    local procedure SetLastModifiedDateTime()
    begin
        "Last Modified DateTime" := CurrentDateTime;
        "User ID" := UserId;
    end;
}