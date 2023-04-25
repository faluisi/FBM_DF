codeunit 61500 FBM_Migration_DF
{
    var
        window: Dialog;
        nrec: Integer;
        crec: integer;
        ntable: text[100];
        comp: record Company;
        Termsconditions_old: record TermsConditions;
        Termsconditions_new: record FBM_TermsConditions;
        customer: record Customer;
        fbmcust: record FBM_Customer;
        site_old: record "Customer-Site";
        site_new: record FBM_Site;
        cos: record "Cust-Op-Site";
        cos_new: record FBM_CustOpSite;
        compinfo: record "Company Information";
        custLE: record "Cust. Ledger Entry";
        detCustLE: record "Detailed Cust. Ledg. Entry";
        fa: record "Fixed Asset";
        GenJnlLine: record "Gen. Journal Line";
        glaccount: record "G/L Account";
        glentry: record "G/L Entry";
        sheader: record "Sales Header";
        sline: record "Sales Line";

        siheader: record "Sales Invoice Header";
        siline: record "Sales Invoice Line";
        scheader: record "Sales Cr.Memo Header";
        scline: record "Sales Cr.Memo Line";
        salessetup: record "Sales & Receivables Setup";
        usetup: record "User Setup";
        vendorle: record "Vendor Ledger Entry";
        detvendorle: record "Detailed Vendor Ledg. Entry";
        vendor: record Vendor;
        bankacc: record "Bank Account";
        itemle: record "Item Ledger Entry";
        SalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer";

    procedure dataMigration()
    begin
        window.open('#1#######/#2#######/#3#######');

        if comp.FindFirst() then begin
            repeat
                compinfo.ChangeCompany(comp.Name);
                compinfo.get;
                if compinfo.FBM_Migration then begin
                    Termsconditions_old.ChangeCompany(comp.Name);
                    Termsconditions_new.ChangeCompany(comp.Name);
                    nrec := Termsconditions_old.Count;
                    ntable := Termsconditions_old.TableCaption;
                    crec := 0;
                    Termsconditions_new.DeleteAll();
                    if Termsconditions_old.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            Termsconditions_new.Init();
                            Termsconditions_new.Country := Termsconditions_old.Country;
                            Termsconditions_new."Line No." := Termsconditions_old."Line No.";
                            Termsconditions_new."Terms Conditions" := Termsconditions_old."Terms Conditions";
                            Termsconditions_new.DocType := Termsconditions_old.DocType;
                            Termsconditions_new.Insert();
                        until Termsconditions_old.Next() = 0;
                    customer.ChangeCompany(comp.Name);
                    nrec := customer.count;
                    crec := 0;
                    ntable := customer.TableCaption;
                    if customer.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            if not fbmcust.get(customer."No. 2") then begin
                                fbmcust.init;
                                fbmcust.TransferFields(customer, false);
                                fbmcust.FBM_Group := customer.Group;
                                fbmcust.FBM_SubGroup := customer.SubGroup;
                                fbmcust."FBM_Separate Halls Inv." := customer."Separate Halls Inv.";
                                fbmcust."FBM_Customer Since" := customer."Customer Since";

                                fbmcust."No." := customer."No. 2";
                                fbmcust."Valid From" := Today;
                                fbmcust."Record Owner" := UserId;
                                fbmcust.Active := true;
                                fbmcust.Insert();

                            end;
                            customer."FBM_Separate Halls Inv." := customer."Separate Halls Inv.";
                            customer."FBM_Customer Since" := customer."Customer Since";
                            customer.FBM_GrCode := customer."No. 2";
                        until customer.Next() = 0;
                    nrec := cos.count;
                    crec := 0;
                    ntable := cos.TableCaption;
                    cos.ChangeCompany(comp.Name);
                    cos_new.DeleteAll();
                    if cos.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            cos_new.Init();
                            cos_new."Customer No." := cos."Customer No.";

                            cos_new."Operator No." := cos."Customer No.";
                            if cos."Site Code 2" <> '' then
                                cos_new."Site Code" := cos."Site Code 2"
                            else
                                cos_new."Site Code" := cos."Site Code";
                            cos_new."Valid From" := Today;
                            cos_new."Record Owner" := UserId;

                            if cos_new.Insert() then begin
                            end;
                        until cos.Next() = 0;
                    site_old.ChangeCompany(comp.Name);
                    nrec := site_old.count;
                    crec := 0;
                    ntable := site_old.TableCaption;
                    site_new.DeleteAll();
                    if site_old.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            cos.SetRange("Site Code", site_old."Site Code");
                            if cos.FindFirst() and not site_new.get(cos."Site Code 2") then begin
                                site_new.Init();
                                site_new."Site Code" := cos."Site Code 2";
                                site_new."Site Name" := site_old."Site Name";
                                site_new.Address := site_old.Address;
                                site_new."Address 2" := site_old."Address 2";
                                site_new.City := site_old.City;
                                site_new."Post Code" := site_old."Post Code";
                                site_new."Country/Region Code" := site_old."Country/Region Code";
                                site_new.Indent := site_old.Indent;
                                site_new."Contract Code" := site_old."Contract Code";
                                site_new."Vat Number" := cos."Vat Number";
                                site_new.Status := site_old.Status;
                                site_new."Site Code" := cos."Site Code 2";
                                site_new."Valid From" := Today;
                                site_new."Record Owner" := UserId;
                                site_new.Active := true;
                                site_new.Insert()
                            end;
                        until site_old.Next() = 0;


                    compinfo.ChangeCompany(comp.Name);
                    nrec := compinfo.count;
                    crec := 0;
                    ntable := compinfo.TableCaption;
                    if compinfo.FindFirst() then begin
                        crec += 1;
                        winupdate(nrec, crec, comp.Name, ntable);
                        compinfo."FBM_TINNumber" := compinfo."TIN Number";
                        compinfo.Modify();
                    end;
                    custLE.ChangeCompany(comp.Name);
                    nrec := custLE.count;
                    crec := 0;
                    ntable := custLE.TableCaption;
                    if custLE.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            custLE."FBM_Period End" := custLE."Period End";
                            custLE."FBM_Period Start" := custLE."Period Start";
                            if (siheader.get(custLE."Document No.")) or (scheader.get(custLE."Document No.")) then begin
                                SalesCrMemoEntityBuffer.SetRange("Cust. Ledger Entry No.", custLE."Entry No.");
                                SalesCrMemoEntityBuffer.SetRange(Posted, true);
                                if not SalesCrMemoEntityBuffer.IsEmpty then
                                    if scheader.get(SalesCrMemoEntityBuffer."No.") then
                                        custLE.Modify();
                            end;
                        until custLE.Next() = 0;
                    detcustLE.ChangeCompany(comp.Name);
                    nrec := detCustLE.count;
                    crec := 0;
                    ntable := detCustLE.TableCaption;
                    if detcustLE.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            detcustLE."FBM_Period End" := detcustLE."Period End";
                            detcustLE."FBM_Period Start" := detcustLE."Period Start";
                            detcustLE.Modify();
                        until detcustLE.Next() = 0;
                    fa.ChangeCompany(comp.Name);
                    nrec := fa.count;
                    crec := 0;
                    ntable := fa.TableCaption;
                    if fa.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            fa."FBM_Date Prepared" := fa."Date Prepared";
                            fa."FBM_Fa Posting Group Depr" := fa."Fa Posting Group Depr";
                            fa.FBM_Group := fa.Group;
                            fa.FBM_Hall := fa.Hall;
                            fa."FBM_Hall Status" := fa."Hall Status";
                            fa.FBM_Location := fa.Location;
                            fa."FBM_Operator Name" := fa."Operator Name";
                            fa."FBM_Business Name" := fa."Business Name";
                            fa.modify;
                        until fa.Next() = 0;
                    GenJnlLine.ChangeCompany(comp.Name);
                    nrec := GenJnlLine.count;
                    crec := 0;
                    ntable := GenJnlLine.TableCaption;
                    if GenJnlLine.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            GenJnlLine."FBM_Period Start" := GenJnlLine."Period Start";
                            GenJnlLine."FBM_Period End" := GenJnlLine."Period End";
                            GenJnlLine.Modify();
                        until GenJnlLine.Next() = 0;
                    glaccount.ChangeCompany(comp.Name);
                    nrec := glaccount.count;
                    crec := 0;
                    ntable := glaccount.TableCaption;
                    if glaccount.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            glaccount."FBM_Periods Required" := glaccount."Periods Required";
                            glaccount.Modify();
                        until glaccount.Next() = 0;
                    glentry.ChangeCompany(comp.Name);
                    nrec := glentry.count;
                    crec := 0;
                    ntable := glentry.TableCaption;
                    if glentry.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            glentry."FBM_Period Start" := glentry."Period Start";
                            glentry."FBM_Period End" := glentry."Period End";
                            glentry.Modify();
                        until glentry.Next() = 0;
                    sheader.ChangeCompany(comp.Name);
                    nrec := sheader.count;
                    crec := 0;
                    ntable := sheader.TableCaption;
                    if sheader.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            sheader."FBM_Billing Statement" := sheader."Billing Statement";
                            sheader."FBM_Contract Code" := sheader."Contract Code";
                            sheader.FBM_Site := sheader.Site;
                            sheader."FBM_Period Start" := sheader."Period Start";
                            sheader."FBM_Period End" := sheader."Period End";
                            sheader.Modify();
                        until sheader.Next() = 0;
                    sline.ChangeCompany(comp.Name);
                    nrec := sline.count;
                    crec := 0;
                    ntable := sline.TableCaption;
                    if sline.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            sline.FBM_IsPeriodEnabled := sline.IsPeriodEnabled;
                            sline.FBM_Site := sline.Site;
                            sline."FBM_Period Start" := sline."Period Start";
                            sline."FBM_Period End" := sline."Period End";
                            sline.Modify();
                        until sline.Next() = 0;
                    siheader.ChangeCompany(comp.Name);
                    nrec := siheader.count;
                    crec := 0;
                    ntable := siheader.TableCaption;
                    if siheader.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            siheader."FBM_Billing Statement" := siheader."Billing Statement";
                            siheader."FBM_Contract Code" := siheader."Contract Code";
                            siheader.FBM_Site := siheader.Site;
                            siheader."FBM_Period Start" := siheader."Period Start";
                            siheader."FBM_Period End" := siheader."Period End";
                            siheader.Modify();
                        until siheader.Next() = 0;
                    siline.ChangeCompany(comp.Name);
                    nrec := siline.count;
                    crec := 0;
                    ntable := siline.TableCaption;
                    if siline.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            siline.FBM_Site := siline.Site;
                            siline."FBM_Period Start" := siline."Period Start";
                            siline."FBM_Period End" := siline."Period End";
                            siline.Modify();
                        until siline.Next() = 0;
                    scheader.ChangeCompany(comp.Name);
                    nrec := scheader.count;
                    crec := 0;
                    ntable := scheader.TableCaption;
                    if scheader.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            scheader."FBM_Contract Code" := scheader."Contract Code";
                            scheader.FBM_Site := scheader.Site;
                            scheader."FBM_Period Start" := scheader."Period Start";
                            scheader."FBM_Period End" := scheader."Period End";
                            scheader.Modify();
                        until scheader.Next() = 0;
                    scline.ChangeCompany(comp.Name);
                    nrec := scline.count;
                    crec := 0;
                    ntable := scline.TableCaption;
                    if scline.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            scline.FBM_Site := scline.Site;
                            scline."FBM_Period Start" := scline."Period Start";
                            scline."FBM_Period End" := scline."Period End";
                            scline.Modify();
                        until scline.Next() = 0;
                    salessetup.ChangeCompany();
                    nrec := salessetup.count;
                    crec := 0;
                    ntable := salessetup.TableCaption;
                    if salessetup.Get() then begin
                        crec += 1;
                        winupdate(nrec, crec, comp.Name, ntable);
                        salessetup."FBM_Show Hall Invoice Warning" := salessetup."Show Hall Invoice Warning";
                        salessetup.Modify();
                    end;
                    usetup.ChangeCompany(comp.Name);
                    nrec := usetup.count;
                    crec := 0;
                    ntable := usetup.TableCaption;
                    if usetup.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            usetup."FBM_See LCY in Journals" := usetup."See LCY in Journals";
                            usetup."FBM_Approve Finance" := usetup."Approve Finance";
                            usetup."FBM_Item Filter" := usetup."Item Filter";
                            usetup."FBM_Bank Filter" := usetup."Bank Filter";
                            usetup.Modify();
                        until usetup.Next() = 0;
                    vendorle.ChangeCompany(comp.Name);
                    nrec := vendorle.count;
                    crec := 0;
                    ntable := vendorle.TableCaption;
                    if vendorle.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            vendorle.FBM_approved := vendorle.approved;
                            vendorle."FBM_approved date" := vendorle."approved date";
                            vendorle."FBM_approved user" := vendorle."approved user";
                            vendorle."FBM_Approver Comment" := vendorle."Approver Comment";

                            vendorle."FBM_Default Bank Account" := vendorle."Default Bank Account";
                            vendorle.Modify();
                        until vendorle.Next() = 0;
                    detvendorle.ChangeCompany(comp.Name);
                    nrec := detvendorle.count;
                    crec := 0;
                    ntable := detvendorle.TableCaption;
                    if detvendorle.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            detvendorle."FBM_Default Bank Account" := detvendorle."Default Bank Account";
                            detvendorle.FBM_approved := detvendorle.approved;
                            detvendorle.FBM_open := detvendorle.open;
                            detvendorle.Modify();
                        until detvendorle.Next() = 0;
                    vendor.ChangeCompany(comp.Name);
                    nrec := vendor.count;
                    crec := 0;
                    ntable := vendor.TableCaption;
                    if vendor.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            vendor."FBM_Default Bank Account" := vendor."Default Bank Account";
                            vendor."FBM_Print Name on Check" := vendor."Print Name on Check";
                            vendor.Modify();
                        until vendor.Next() = 0;
                    bankacc.ChangeCompany(comp.Name);
                    nrec := bankacc.count;
                    crec := 0;
                    ntable := bankacc.TableCaption;
                    if bankacc.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            bankacc."FBM_Approval Batch Amount" := bankacc."Approval Batch Amount";
                            bankacc."FBM_Approval Batch Amount2" := bankacc."Approval Batch Amount2";
                            bankacc.Modify();
                        until bankacc.Next() = 0;
                    itemle.ChangeCompany(comp.Name);
                    nrec := itemle.count;
                    crec := 0;
                    ntable := itemle.TableCaption;
                    if itemle.FindFirst() then
                        repeat
                            crec += 1;
                            winupdate(nrec, crec, comp.Name, ntable);
                            itemle."FBM_Document No Value Entry" := itemle."Document No Value Entry";
                            itemle.Modify();
                        until itemle.Next() = 0;
                end;
            until comp.Next() = 0;
        end;
    end;


    local procedure winupdate(NoOfRecs: integer; CurrRec: integer; ntable: text[100]; compname: text[100])
    begin
        window.Update(1, compname);
        window.Update(2, ntable);
        if NoOfRecs > 0 then
            IF NoOfRecs <= 100 THEN
                Window.UPDATE(3, (CurrRec / NoOfRecs * 10000) DIV 1)
            ELSE
                IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                    Window.UPDATE(3, (CurrRec / NoOfRecs * 10000) DIV 1);

    end;
}