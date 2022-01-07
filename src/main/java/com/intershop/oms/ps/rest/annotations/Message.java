package com.intershop.oms.ps.rest.annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import bakery.persistence.dataobject.configuration.connections.MessageTypeDefDO;

/**
 * <p>
 * Annotation für Methoden der REST-Services.
 * <p>
 * <p>
 * Wird verwendet, um Eigenschaften der Methode z.B. für das Logging näher zu spezifizieren.
 * </p>
 * 
 * @author matthiasf
 *
 */
@Retention( RetentionPolicy.RUNTIME )
@Target( ElementType.METHOD )
public @interface Message {

	/**
	 * Gibt den zu dieser Methode gehörenden MessageType an. Dieser wird z.B. im OrderMessageLog verwendet. 
	 * 
	 * @return
	 */
	public MessageTypeDefDO messageType();

}
