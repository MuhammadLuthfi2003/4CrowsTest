import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Inventory {
    public HashMap<String, Integer> Registry;

    public Inventory()
    {
        this.Registry = new HashMap<>();
    }

    public boolean HasItem(String itemName)
    {
        if (itemName == null) {
            return false;
        }

        return Registry.containsKey(itemName);
    }

    public Integer GetItemAmount(String itemName)
    {
        if (itemName == null) {
            System.err.println("Error!, Invalid Datatype");
            return null;
        }
        
        // check if item is in registry
        if (!HasItem(itemName))
        {
            System.err.println("Error!, Item Not In Registry!");
            return null;
        } 

        return Registry.get(itemName);
    }

    // amount here is amount to add, NOT the initial amount
    public void AddItem(String itemName, Integer amount)
    {
        if (itemName == null || amount == null) {
            System.err.println("Error!, Invalid Datatype");
            return;
        }

        if (amount < 0) {
            System.err.println("Error!, Negative Numbers not allowed!");
            return;
        }

        // add new registry
        if (!HasItem(itemName)) {
            Registry.put(itemName, amount);
        }
        // add value to existing registry
        else {
            // get existing amount
            Integer currAmt = GetItemAmount(itemName);
            currAmt += amount;
            Registry.put(itemName, currAmt);
        }

        System.out.println("Success, current amount for " + itemName.toString() + " is " + GetItemAmount(itemName).toString() );
    }

    public void RemoveItem(String itemName, Integer amount)
    {
        if (itemName == null || amount == null) {
            System.err.println("Error!, Invalid Datatype");
            return;
        }

        if (!HasItem(itemName)) {
            System.err.println("Error!, " + itemName + " Not In Registry");
            return;
        }

        if (GetItemAmount(itemName) < amount)
        {
            System.err.println("Error!, Requested Item Amount Exceed Item Count for " + itemName +  " in Inventory!");
            return;
        }

        Integer currAmt = GetItemAmount(itemName);
        currAmt -= amount;
        Registry.put(itemName, currAmt);

        System.out.println("Success, current amount for " + itemName.toString() + " is " + GetItemAmount(itemName).toString() );
    }

    // prints out the entire registry
    public void GetAllItems()
    {
        System.out.println("Your Current Inventory:");

        for (Map.Entry<String, Integer> entry : Registry.entrySet()) {
            String itemName = entry.getKey();
            Integer amount = entry.getValue();

            System.out.println(itemName + " x" + amount);
        }

        System.out.println("=====================================================");
    }

    public void GetTopItems(Integer limit)
    {
        if (limit == null) {
            limit = Registry.size();
        }

        // creates a list that contains hashmap entries
        List<Map.Entry<String, Integer>> sortedItems =
        new ArrayList<>(Registry.entrySet());

        // sort based on its values
        sortedItems.sort(
            Map.Entry.<String, Integer>comparingByValue().reversed()
        );


        // get hashmap length so that if limit exceeds the count, no errors will happen
        if (limit > Registry.size())
        {
            limit = Registry.size();
        }

        System.out.println("Top Items :");
        // prints out the value
        for (int i = 0; i < limit; i++ )
        {
            Map.Entry<String, Integer> item = sortedItems.get(i);

            System.out.println((i+1) + ". " + item.getKey() + " x" + item.getValue());
        }
        System.out.println("=====================================================");
    }
}
