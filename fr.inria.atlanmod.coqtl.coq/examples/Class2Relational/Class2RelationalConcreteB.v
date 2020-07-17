Require Import String.
Require Import List.
Require Import Multiset.
Require Import ListSet.
Require Import Omega.

Require Import core.utils.TopUtils.

Require Import core.ConcreteSyntaxB.
Require Import core.Semantics.
Require Import core.Metamodel.
Require Import core.Expressions.

Require Import Class2Relational.ClassMetamodel.
Require Import Class2Relational.RelationalMetamodel.

(* module Class2Relational; 
   create OUT : RelationalMetamodel from IN : ClassMetamodel;

   rule Class2Table {
       from 
         c : Class
       to 
         tab: Table (
           id <- c.id,
           name <- c.name,
           columns <- c.attributes->collect(a | thisModule.resolve(a, 'col'))
         )
    }
    rule Attribute2Column {
        from 
          a : Attribute (not a.derived)
        to 
          col: Column (
            id <- a.id,
            name <- a.name,
            reference <- thisModule.resolve(a.type, 'tab')
          )
    }
   } *)

Open Scope coqtlb.

Definition Class2Relational :=
  transformation ClassMetamodel RelationalMetamodel
  [
    rule "Class2Table"
    from [ClassEClass]
    to [elem [ClassEClass] TableClass "tab"
        (fun i m c => return BuildTable (getClassId c) (getClassName c))
        [link [ClassEClass] TableClass TableColumnsReference
          (fun tls i m c t =>
            attrs <- getClassAttributes c m;
            cols <- resolveAll tls m "col" ColumnClass 
              (singletons (map (A:=Attribute) ClassMetamodel_toEObject attrs));
            return BuildTableColumns t cols)]]
            (*
            return (map (resolve tls m "col" ColumnClass) (singletons (getClassAttributes c m)))
             *)
    ;
    rule "Attribute2Column"
    from [AttributeEClass]
    where (fun m a => return negb (getAttributeDerived a))
    to [elem [AttributeEClass] ColumnClass "col"
        (fun i m a => return (BuildColumn (getAttributeId a) (getAttributeName a)))
        [link [AttributeEClass] ColumnClass ColumnReferenceReference
          (fun tls i m a c =>
            cl <- getAttributeType a m;
            tb <- resolve tls m "tab" TableClass [ClassMetamodel_toEObject cl];
            return BuildColumnReference c tb)]]
  ].

Close Scope coqtlb.
