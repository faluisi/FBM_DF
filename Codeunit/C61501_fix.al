codeunit 61501 Fixes
{
    Permissions = tabledata "Purch. Inv. Line" = rimd, tabledata "G/L Entry" = rimd;
    procedure fixqty()

    var
        pinvline: record "Purch. Inv. Line";
    begin
        pinvline.SetRange("Document No.", 'P-APV003105');
        pinvline.SetRange("Line No.", 610000);
        if pinvline.FindFirst() then begin
            pinvline.Validate(Quantity, 1);
            pinvline.Modify();
        end;


    end;

    procedure fixic()
    var
        paric: record "IC Partner";
    begin
        paric.SetRange(code, 'IC0012');
        IF PARIC.FindFirst() THEN BEGIN
            PARIC."Vendor No." := 'VIC112';
            paric.Modify();
        END;
    end;

    procedure fixpo()
    var
        pline: record "Purchase Line";
    begin
        pline.SetRange("Document Type", pline."Document Type"::Order);
        pline.SetRange("Document No.", '005148');
        pline.SetRange("Line No.", 10000);
        if pline.FindFirst() then begin
            pline."Prepayment Amount" := 0;
            pline."Prepmt. Amt. Incl. VAT" := 0;
            pline."Prepmt. Amount Inv. Incl. VAT" := 859485.86;
            pline."Prepmt. Line Amount" := 859485.87;
            pline."Prepmt. VAT Base Amt." := 0;
            pline."Prepmt. Amt. Inv." := 859485.86;
            pline.Modify();
        end;

    end;

    procedure fixitem()
    var
        item: record item;
    begin
        if item.get('598522') then begin
            item."Unit Cost" := 960;
            item.Modify()
        end;
    end;

    procedure deletelog()
    var
        changelog: record "Change Log Entry";
    begin
        changelog.DeleteAll();
        message('Done');
    end;

    procedure setpermset(permset: code[20]; action: Integer)
    var
        acccont: record "Access Control";
        user: record user;
    begin
        user.SetRange(State, user.state::Enabled);
        if user.FindFirst() then
            repeat
                acccont.SetRange("User Name", user."User Name");
                acccont.SetRange("Role ID", permset);
                if action = 0 then begin
                    if acccont.FindFirst() then
                        acccont.Delete();

                end
                else
                    if acccont.IsEmpty then begin
                        acccont.Init();
                        acccont.validate("User Security ID", user."User Security ID");
                        acccont.validate("Role ID", permset);
                        acccont.Validate(Scope, acccont.Scope::System);
                        acccont.Insert(true);
                    end;

            until user.next = 0;
        message('Done');
    end;

    procedure fixacy()
    var
        glentry: record "G/L Entry";
        exchrate: record "Currency Exchange Rate";
        crec: integer;
    begin
        exchrate.ChangeCompany('FBM Ltd');
        glentry.SetFilter("Posting Date", '>=%1 & <=%2', DMY2Date(19, 04, 2023), DMY2Date(20, 04, 2023));
        if glentry.FindFirst() then
            repeat
                if glentry."Additional-Currency Amount" = glentry.Amount then begin
                    if abs(glentry.Amount) > 1 then begin
                        crec += 1;
                        exchrate.get('PHP', glentry."Posting Date");
                        glentry.validate("Additional-Currency Amount", glentry.Amount / exchrate."Exchange Rate Amount");
                        glentry.Modify();
                    end;
                end;
            until glentry.Next() = 0;
        message(format(crec));
    end;




}