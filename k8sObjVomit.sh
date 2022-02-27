#!/bin/bash

##Clear previous files used in script
rm test.txt 
rm ns.txt 
rm k8sresources.txt


####Grabbing k8s Namespaces
$(kubectl get ns | cut -d' ' -f1 > ns.txt)
$(touch ns2.txt)
echo "---Grabbing k8s cluster namespaces-------"
while IFS= read -r line
do
  if [ $line != "NAME" ]
  then echo "$line" && echo $line >> ns2.txt
  fi
done < ns.txt
echo "------------------------------------------"
$(rm ns.txt)
$(cat ns2.txt > ns.txt)
$(rm ns2.txt)

####Grabbing k8s Resources
DataList=$(kubectl api-resources --namespaced=true --verbs=delete -o name | tr "\n" "," | sed -e 's/,$//')
Field_Separator=$IFS

# set comma as internal field separator for the string list
IFS=,
echo "---Gathering k8s resources----------------"
for val in $DataList;
do
echo $val
echo $val >> k8sresources.txt
done
echo "--------------------------------------------"

IFS=$Field_Separator
while IFS= read -r ns
do
  echo "--------------------------------------------------"
  echo "--NAMESPACE---$ns-------------"
  echo "--------------------------------------------------"
  for resource in $(cat ./k8sresources.txt);
  do
    (kubectl -n $ns get $resource) 2>&1 | tee > test.txt
    #cat test.txt
    if grep -q "No resources found" test.txt; #then echo "yes"; fi
    #if [ "((kubectl -n $ns get $resource 2>&1) | tee)" != *"No resources found"* ]
      then
	:
      else
        echo "--------------------------------------------------"
        echo "--$ns--$resource---"
        echo "--------------------------------------------------"
        kubectl -n $ns get $resource
    fi
  done
done < ns.txt

###Clear files used in script
rm test.txt
rm ns.txt
rm k8sresources.txt
