public class App {
    public static void main(String[] args) throws Exception {

        Inventory myInventory = new Inventory();

        // item creation
        // create some items
        System.out.println("Item Creation");
        myInventory.AddItem("Wrench", 10);
        myInventory.AddItem("Coffee", 5);
        myInventory.AddItem("Coins", 30);
        System.out.println("=================================================");

        // add item
        // add some amount to currently existing item
        System.out.println("Item Addition");
        myInventory.AddItem("Wrench", 5);
        System.out.println("=================================================");

        // remove item
        // remove some amount of currently existing item
        System.out.println("Item Removal");
        myInventory.RemoveItem("Coins", 20);
        System.out.println("=================================================");

        // Display All
        // get all current items in inventory
        myInventory.GetAllItems();

        // Get Top Items
        myInventory.GetTopItems(2);

        // Edge Cases
        // since java is a static language, there is not much edge cases that can be checked, other than checking for null
        // or checking for specific cases like too much amount to remove
        System.out.println("Edge Cases");
        System.out.println("1. Item Creation with Null Parameter");
        myInventory.AddItem("FlashDisk", null);

        System.out.println("2. Item Creation with Negative Values");
        myInventory.AddItem("Coffee", -30);

        System.out.println("3. Item Removal with Item Not Existing in Registry");
        myInventory.RemoveItem("FlashDisk", 10);

        System.out.println("4. Item Removal with Count Exceeding in Registry");
        // coins currently has 10, so try 20 and a log message will print out
        myInventory.RemoveItem("Coins", 20);

        System.out.println("5. Get Top Items with limit exceeding inventory count");
        myInventory.GetTopItems(500);


    }
}
