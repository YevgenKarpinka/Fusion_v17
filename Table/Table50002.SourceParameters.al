table 50002 "Source Parameters"
{
    DataClassification = ToBeClassified;
    CaptionML = ENU = 'Source Parameters', RUS = 'Параметры подключения';

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = SystemMetadata;
            CaptionML = ENU = 'Code', RUS = 'Код';
        }
        field(2; "FSp RestMethod"; Option)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'FSp RestMethod', RUS = 'FSp RestMethod';
            OptionMembers = GET,POST;
            OptionCaptionML = ENU = 'GET,POST', RUS = 'GET,POST';
            NotBlank = true;
        }
        field(3; "FSp URL"; Text[200])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'FSp URL', RUS = 'FSp URL';
            NotBlank = true;
        }
        field(4; "FSp Accept"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'FSp Accept', RUS = 'FSp Accept';
        }
        field(5; "FSp AuthorizationFrameworkType"; Option)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'FSp Authorization Framework Type', RUS = 'FSp Authorization Framework Type';
            OptionMembers = " ",BasicHTTP,OAuth2;
            OptionCaptionML = ENU = ' ,Basic HTTP,OAuth2', RUS = ' ,Basic HTTP,OAuth2';
            NotBlank = true;
        }
        field(6; "FSp AuthorizationToken"; Text[200])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'FSp Authorization Token', RUS = 'FSp Authorization Token';
        }
        field(7; "FSp UserName"; Text[100])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'FSp UserName', RUS = 'FSp UserName';
            NotBlank = true;
        }
        field(8; "FSp Password"; Text[100])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'FSp Password', RUS = 'FSp Password';
            NotBlank = true;
        }
        field(9; "FSp ContentType"; Option)
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'FSp ContentType', RUS = 'FSp ContentType';
            OptionMembers = " ","application/json","application/x-www-form-urlencoded";
            OptionCaptionML = ENU = ' ,application/json,application/x-www-form-urlencoded', RUS = ' ,application/json,application/x-www-form-urlencoded';
        }
        field(10; "FSp ETag"; Text[100])
        {
            DataClassification = CustomerContent;
            CaptionML = ENU = 'FSp E-Tag', RUS = 'FSp E-Tag';
        }
        field(11; "FSp Event"; Option)
        {
            CaptionML = ENU = 'FSp Event', RUS = 'FSp Событие';
            OptionMembers = " ",getOrder,createOrder,createLabel,getCarriers,getServices,getCarrier,postRate,postVoidLabel;
            OptionCaptionML = ENU = ' ,getOrder,createOrder,createLabel,getCarriers,getServices,getCarrier,postRate,postVoidLabel',
                              RUS = ' ,получить Ордер,создать Ордер,создать Метку,получить Курьеров,получить Сервисы,получить Курьера,получить Стоимость,отменить Метку';
            NotBlank = true;
        }
        field(12; "HTTP Status Ok"; Integer)
        {
            CaptionML = ENU = 'HTTP Status Ok', RUS = 'HTTP Статус Ok';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}