package it.distributedsystems.model.dao;

import java.util.Set;

public interface CartDAO {

    public void addItem(Product product);

    public Set<Product> getItems();

    public void removeAllItems();
}
