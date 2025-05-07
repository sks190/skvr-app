document.addEventListener('DOMContentLoaded', function () {
    
    const clear = document.getElementById('clearFacets');
    
    pbEvents.subscribe('pb-login', null, function(ev) {
        if (ev.detail.userChanged) {
            pbEvents.emit('pb-search-resubmit', 'search');
        }
    });

    /* Parse the content received from the server */
    pbEvents.subscribe('pb-results-received', 'search', function(ev) {
        const { content } = ev.detail;
        /* Check if the server passed an element containing the current 
           collection in attribute data-root */
        const root = content.querySelector('[data-root]');
        const currentCollection = root ? root.getAttribute('data-root') : "";
        const writable = root ? root.classList.contains('writable') : false;
        
        /* Report the current collection and if it is writable.
           This is relevant for e.g. the pb-upload component */
        pbEvents.emit('pb-collection', 'search', {
            writable,
            collection: currentCollection
        });
        /* hide any element on the page which has attribute can-write */
        document.querySelectorAll('[can-write]').forEach((elem) => {
            elem.disabled = !writable;
        });

        /* Scan for links to collections and handle clicks */
        content.querySelectorAll('[data-collection]').forEach((link) => {
            link.addEventListener('click', (ev) => {
                ev.preventDefault();

                const collection = link.getAttribute('data-collection');
                // write the collection into a hidden input and resubmit the search
                document.querySelector('.options [name=collection]').value = collection;
                pbEvents.emit('pb-search-resubmit', 'search');
            });
        });
    });
    
    const facets = document.querySelector('#facets');
    if (facets) {
        facets.addEventListener('pb-custom-form-loaded', function(ev) {
            const elems = ev.detail.querySelectorAll('.facet');
            const checked = ev.detail.querySelectorAll('.facet:checked');            
            // add event listener to facet checkboxes
            elems.forEach(facet => {
                facet.addEventListener('change', () => {
                    if (!facet.checked) {
                        pbRegistry.state[facet.name] = null;
                    }
                    const table = facet.closest('table');
                    if (table) {
                        const nested = table.querySelectorAll('.nested .facet').forEach(nested => {
                            if (nested != facet) {
                                nested.checked = false;
                            }
                        });
                    }
                    if (facet.name == 'facet-genre') {
                        facets.submit();
                    } else {
                        return;
                    }                    
                });

            }); 
            
            ev.detail.querySelectorAll('pb-combo-box').forEach((select) => {
                select.renderFunction = (data, escape) => {
                    if (data) {
                        return `<div>${escape(data.text)} <span class="freq">${escape(data.freq || '')}</span></div>`;
                    }
                    return '';
                }
            });
            
        });
        
        // if there's a combo box, synchronize any changes to it with existing checkboxes
        pbEvents.subscribe('pb-combo-box-change', null, function(ev) {
            const parent = ev.target.parentNode;
            const values = ev.detail.value;
            // walk through checkboxes and select the ones in the combo box
            parent.querySelectorAll('.facet').forEach((cb) => {
                const idx = values.indexOf(cb.value);
                cb.checked =  idx > -1;
                if (cb.checked) {
                    values.splice(values.length, 1);
                }
            });         
            
        });
        
        function uncheckAll() {
            document.querySelectorAll('.facet').forEach(el => el.checked = false);
            var pcb = document.querySelector('pb-combo-box[placeholder="Numero"]');
            var select = pcb.querySelector('select');
            if (select.options[select.selectedIndex]) {
                select.options[select.selectedIndex].selected = false;            
            }
            facets.submit();
        }
        
        clear.addEventListener('click', uncheckAll);
    }
});
