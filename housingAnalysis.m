%% Data Aquisition 

%Read html
this = webread("https://www.bostonmagazine.com/property/single-family-home-prices/");

%Parser 
tree = htmlTree( this );

%Extraction tag
selector = "TR";
subtrees = findElement(tree,selector);

%Read header 
str  = findElement( subtrees(1), "TH" );
vars = transpose( extractHTMLText(str) );   

%Drop header
subtrees(1) = [];

value = strings( numel(subtrees), numel(vars) );
for iItem = 1:numel(subtrees)
    
    this = findElement(subtrees(iItem),"TD");
    value(iItem,:)  = transpose( extractHTMLText(this) );

end %for iItem

%Check for empty items  
assert( all( value(:,1) ~= "" ) )


%% Data preparation 

%Format Pricing 
iD = find( contains(vars, "Price") );
for iVar = iD(:)'
    value(:,iVar) = replace(value(:,iVar),{'$', ','},'');
end %for iVar

%Format Percentages
iD = find( contains(vars, "Change") );
for iVar = iD(:)'
    value(:,iVar) = replace(value(:,iVar),'%','');
end %for iVar

%Convert features from strings to numerics 
array = double( value(:,2:end) );

%Create a table, with City/Town identifiers 
data = table();
data.( vars(1) ) = value(:,1);

%Convert features to table
numerics = array2table(array, 'VariableNames', vars(2:end));

%Concatenate 
data = horzcat(data, numerics);


%% Data Export 

if ~isfolder( fullfile(pwd, "data") )
   mkdir( fullfile(pwd, "data") ) 
end

parquetwrite( fullfile(pwd, "data", "BostonHousing2019.parquet"), data )




