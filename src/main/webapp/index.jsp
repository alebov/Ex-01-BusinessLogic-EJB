<%@ page session ="true"%>
<%@ page import="java.util.*" %>
<%@ page import="it.distributedsystems.model.dao.*" %>


<%!
	String printTableRow(Product product, String url) {
		StringBuffer html = new StringBuffer();
		html
				.append("<tr>")
				.append("<td>")
				.append(product.getName())
				.append("</td>")

				.append("<td>")
				.append(product.getProductNumber())
				.append("</td>")

				.append("<td>")
				.append( (product.getProducer() == null) ? "n.d." : product.getProducer().getName() )
				.append("</td>");

		html
				.append("</tr>");

		return html.toString();
	}

	String printCartItem(Product item, String url) {
		StringBuffer html = new StringBuffer();
		html
				.append("<tr>")
				.append("<td>")
				.append(item.getName())
				.append("</td>")

				.append("<td>")
				.append( (item.getProducer() == null) ? "n.d." : item.getProducer().getName() )
				.append("</td>");

		html
				.append("</tr>");

		return html.toString();
	}

	String printTableRows(List products, String url) {
		StringBuffer html = new StringBuffer();
		Iterator iterator = products.iterator();
		while ( iterator.hasNext() ) {
			html.append( printTableRow( (Product) iterator.next(), url ) );
		}
		return html.toString();
	}

	String printCartItems(Set<Product> items, String url) {
		StringBuffer html = new StringBuffer();
		Iterator iterator = items.iterator();
		while ( iterator.hasNext() ) {
			html.append( printCartItem( (Product) iterator.next(), url ) );
		}
		return html.toString();
	}
%>

<html>

	<head>
		<title>HOMEPAGE DISTRIBUTED SYSTEM EJB</title>
	
		<meta http-equiv="Pragma" content="no-cache"/>
		<meta http-equiv="Expires" content="Mon, 01 Jan 1996 23:59:59 GMT"/>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<meta name="Author" content="you">

		<link rel="StyleSheet" href="styles/default.css" type="text/css" media="all" />
	
	</head>
	
	<body>

	<%
		// can't use builtin object 'application' while in a declaration!
		// must be in a scriptlet or expression!
		DAOFactory daoFactory = DAOFactory.getDAOFactory( application.getInitParameter("dao") );
		CustomerDAO customerDAO = daoFactory.getCustomerDAO();
		PurchaseDAO purchaseDAO = daoFactory.getPurchaseDAO();
		ProductDAO productDAO = daoFactory.getProductDAO();
		ProducerDAO producerDAO = daoFactory.getProducerDAO();
		CartDAO cartDAO = daoFactory.getCartDAO();
		if(session.getAttribute("Cart") != null)
		    cartDAO = (CartDAO) session.getAttribute("Cart");

		String operation = request.getParameter("operation");
		if ( operation != null && operation.equals("insertCustomer") ) {
			Customer customer = new Customer();
			customer.setName( request.getParameter("name") );
			int id = customerDAO.insertCustomer( customer );
			out.println("<!-- inserted customer '" + customer.getName() + "', with id = '" + id + "' -->");
			System.out.println("<!-- inserted customer '" + customer.getName() + "', with id = '" + id + "' -->");
		}
		else if ( operation != null && operation.equals("insertProducer") ) {
			Producer producer = new Producer();
			producer.setName( request.getParameter("name") );
			int id = producerDAO.insertProducer( producer );
			out.println("<!-- inserted producer '" + producer.getName() + "', with id = '" + id + "' -->");
			System.out.println("<!-- inserted producer '" + producer.getName() + "', with id = '" + id + "' -->");
		}
		else if ( operation != null && operation.equals("insertProduct") ) {
			Product product = new Product();
			product.setName( request.getParameter("name") );
			product.setProductNumber(Integer.parseInt(request.getParameter("number")));
			Producer producer = producerDAO.findProducerByName(request.getParameter("producer"));
			product.setProducer(producer);
			int id = productDAO.insertProduct(product);
			out.println("<!-- inserted product '" + product.getName() + "' with id = '" + id + "' -->");
			System.out.println("<!-- inserted product '" + product.getName() + "' with id = '" + id + "' -->");
		}
		// Aggiungere oggetti al carrello
		else if ( operation != null && operation.equals("addToCart") ) {
			int productId = Integer.parseInt(request.getParameter("product"));
			Product product = productDAO.findProductById(productId);
			cartDAO.addItem(product);
			session.setAttribute("Cart", cartDAO);
			out.println("<!-- inserted product '" + product.getName() + "' with id = '" + productId + "' in the cart -->");
			System.out.println("<!-- inserted product '" + product.getName() + "' with id = '" + productId + "' in the cart -->");
		}
		// Finalizzare l'ordine degli oggetti
		else if ( operation != null && operation.equals("purchase") ) {
			Purchase purchase = new Purchase();
			purchase.setProducts(cartDAO.getItems());
			purchaseDAO.insertPurchase(purchase);
			// Invalido la sessione, per eliminare gli elementi nel carrello
			session.invalidate();
			cartDAO.removeAllItems();
			out.println("<!-- Purchased products -->");
			System.out.println("<!-- Purchased products -->");
		}

	%>


	<h1>Customer Manager</h1>

	<div>
		<p>Add Customer:</p>
		<form>
			Name: <input type="text" name="name"/><br/>
			<input type="hidden" name="operation" value="insertCustomer"/>
			<input type="submit" name="submit" value="submit"/>
		</form>
	</div>

	<div>
		<p>Add Producer:</p>
		<form>
			Name: <input type="text" name="name"/><br/>
			<input type="hidden" name="operation" value="insertProducer"/>
			<input type="submit" name="submit" value="submit"/>
		</form>
	</div>

	<%
		List producers = producerDAO.getAllProducers();
		if ( producers.size() > 0 ) {
	%>
	<div>
		<p>Add Product:</p>
		<form>
			Name: <input type="text" name="name"/><br/>
			Product Number: <input type="text" name="number"/><br/>
			Producers: <select name="producer">
			<%
				Iterator iterator = producers.iterator();
				while ( iterator.hasNext() ) {
					Producer producer = (Producer) iterator.next();
			%>
			<option value="<%= producer.getName() %>"><%= producer.getName()%></option>
			<%
				}// end while
			%>

			<input type="hidden" name="operation" value="insertProduct"/>
			<input type="submit" name="submit" value="submit"/>
		</form>
	</div>
	<%
		}// end if
		else {
	%>
	<div>
		<p>At least one Producer must be present to add a new Product.</p>
	</div>
	<%
		} // end else
		List<Product> products = productDAO.getAllProducts();
		if(products.size() > 0){
	%>
	<div>
		<p>Products currently in the database:</p>
		<table>
			<tr><th>Name</th><th>ProductNumber</th><th>Producer</th><th></th></tr>
			<%= printTableRows( productDAO.getAllProducts(), request.getContextPath() ) %>
		</table>
	</div>

	<div>
		<p>Add something in the cart:</p>
		<form>
			Product: <select name="product">
				<%
				Iterator iterator2 = products.iterator();
				while ( iterator2.hasNext() ) {
					Product product = (Product) iterator2.next();
			%>
				<option value="<%= product.getId() %>"><%= product.getName()%></option>
				<%
				}// end while
			%>

			<input type="hidden" name="operation" value="addToCart"/>
			<input type="submit" name="submit" value="submit"/>
		</form>
	</div>
	<%
		} // end if
		Set<Product> items = cartDAO.getItems();
		// Se ci sono elementi nel carrello
		if(items.size() > 0){
	%>

	<div>
		<p>Items in the cart:</p>
		<table>
			<tr><th>Name</th><th>Producer</th><th></th></tr>
			<%= printCartItems( items, request.getContextPath() ) %>
		</table>
	</div>

	<div>
		<p>Finalize purchase:</p>
		<form>
			<input type="hidden" name="operation" value="purchase"/>
			<input type="submit" name="submit" value="Compra!"/>
		</form>
	</div>

	<%
		} // end if
	%>
	<div>
		<a href="<%= request.getContextPath() %>">Ricarica lo stato iniziale di questa pagina</a>
	</div>

	</body>

</html>