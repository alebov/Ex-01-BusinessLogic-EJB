package it.distributedsystems.model.ejb;

import it.distributedsystems.model.dao.CartDAO;
import it.distributedsystems.model.dao.Product;

import javax.ejb.Local;
import javax.ejb.Stateful;
import javax.ejb.TransactionAttribute;
import javax.ejb.TransactionAttributeType;
import java.util.HashSet;
import java.util.Set;

@Stateful
@Local(CartDAO.class)
public class EJB3CartDAO implements CartDAO {

//    @PersistenceContext(unitName = "distributed-systems-demo")
//    EntityManager em;

    private Set<Product> products = new HashSet<>();

    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    @Override
    public void addItem(Product product) {
        if(product != null)
            products.add(product);
    }

    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    @Override
    public Set<Product> getItems() {
        return products;
    }

    @TransactionAttribute(TransactionAttributeType.REQUIRED)
    @Override
    public void removeAllItems() {
        products = new HashSet<>();
    }
}
