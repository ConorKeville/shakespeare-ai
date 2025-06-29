<?xml version="1.0" encoding="UTF-8"?>
<!-- tei-to-html.xsl – canonical transform for Folger plays -->
<xsl:stylesheet version="3.0"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:tei="http://www.tei-c.org/ns/1.0"
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xmlns:map="http://www.w3.org/2005/xpath-functions/map"
      expand-text="yes">

<!-- =============================================================
     Dramatis Personae  (front/castList)
     ============================================================= -->
<xsl:template match="tei:castList">
  <section class="dramatis">
    <h2>Dramatis Personae</h2>
    <xsl:apply-templates/>
  </section>
</xsl:template>

<!-- each castGroup -->
<xsl:template match="tei:castGroup">
  <ul class="group">
    <!-- optional heading like “Carriers …” -->
    <xsl:if test="tei:head">
      <li class="grp-head"><strong><xsl:value-of select="tei:head"/></strong></li>
    </xsl:if>
      <xsl:apply-templates select="tei:castItem[tei:role/tei:name]"/>

  </ul>
</xsl:template>

<!-- each castItem -->
<xsl:template match="tei:castItem">
  <li class="role">
    <span class="name">
      <xsl:value-of
        select="normalize-space(string-join(tei:role/tei:name, ' '))"/>
    </span>
    <xsl:if test="tei:roleDesc">
      <span class="desc">
        — <xsl:value-of select="normalize-space(tei:roleDesc)"/>
      </span>
    </xsl:if>
  </li>
</xsl:template>



<!-- POS lookup table – one XPath expression, comments removed -->
<xsl:variable name="posMap"
  select="
    map{
      'n':'noun','n1':'noun','n2':'noun',
      'vvi':'verb','vvb':'verb','vvg':'verb','vvd':'verb','vnb':'verb',
      'vmb':'verb','vmd':'verb',
      'j':'adj','j_vn':'adj',
      'av':'adv','av-q':'adv','av-x_d':'adv','r':'adv',
      'd':'det','d-a':'det','d-c':'det','d-p':'det',
      'pns':'pron','pno':'pron','po':'pron','ppn':'pron',
      'acp-p':'prep','app':'prep',
      'cc':'conj','cs':'conj','acp-cs':'conj',
      'crq-r':'contraction',
      'uh':'interj'
    }"/>



<!-- WORD -->
<xsl:template match="tei:w">
<!-- first POS code after #  (may be empty) -->
<xsl:variable name="raw"
              select="string(tokenize(substring-after(@ana,'#'),'[ |]')[1])"/>

<!-- normalised label or 'other' -->
<xsl:variable name="norm"
              select="if ($raw != '' and map:contains($posMap,$raw))
                      then $posMap($raw)
                      else 'other'"/>



  <span class="w {$norm}" data-posraw="{$raw}" data-lemma="{@lemma}">
    <xsl:value-of select="."/>
  </span>
  <xsl:if test="not(parent::tei:speaker) and not(following-sibling::*[1][self::tei:pc])"><xsl:text> </xsl:text></xsl:if>
</xsl:template>

<!-- PUNCTUATION -->
<xsl:template match="tei:pc">
  <span class="pc"><xsl:value-of select="."/></span>
  <xsl:text> </xsl:text>
</xsl:template>



       <!-- 0.  Global settings-->
       
  <xsl:output method="html" html-version="5"
              indent="no"  encoding="UTF-8"/>

  <!-- identity‑minus: copy nothing we don’t specify -->
  <xsl:mode on-no-match="shallow-skip"/>

  
  <!--  1.  Top‑level wrappers  -->

  <!-- whole play -->
<xsl:template match="tei:TEI">
  <article class="play">
    <!-- front matter first -->
    <xsl:apply-templates select="tei:text/tei:front/tei:castList"/>
    <!-- then the actual play body (acts, scenes, etc.) -->
    <xsl:apply-templates select="tei:text/tei:body/*"/>
  </article>
</xsl:template>

  <!-- act  -->
  <xsl:template match="tei:div[@type='act']">
    <section class="act">
      <h2><xsl:value-of select="tei:head"/></h2>
      <xsl:apply-templates select="node()[not(self::tei:head)]"/>
    </section>
  </xsl:template>

  <!-- scene  -->
  <xsl:template match="tei:div[@type='scene']">
    <section class="scene">
      <h3><xsl:value-of select="tei:head"/></h3>
      <xsl:apply-templates select="node()[not(self::tei:head)]"/>
    </section>
  </xsl:template>

  <!-- 2.  Speech & stage business -->

<!-- swallow the “inline” stage direction we already copied into <h4> -->
<xsl:template match="tei:stage[preceding-sibling::*[1][self::tei:speaker]]"
              priority="2"/>


<!-- inline cue: “reads”, “sings”, etc. -->
<xsl:template match="tei:stage[@type='delivery']" priority="1">
  <span class="stage delivery"><xsl:apply-templates/></span>
</xsl:template>


<!-- block stage direction (entrance, exit, etc.) -->
<xsl:template match="tei:stage">
  <p class="stage {@type}">
    <xsl:apply-templates/>
  </p>
</xsl:template>

 
<!-- speech block -->
<xsl:template match="tei:sp">
  <div class="sp">

    <!-- ▾ speaker line with optional inline stage ▾ -->
    <h4 class="speaker">
      <xsl:apply-templates select="tei:speaker"/>

      <!-- if the very next node is <stage>, tuck it in -->
      <xsl:if test="tei:stage[1][preceding-sibling::*[1][self::tei:speaker]]">
        <xsl:if test="not(tei:stage[1]/tei:pc[1])"><xsl:text> </xsl:text></xsl:if>
        <span class="stage">
          <xsl:apply-templates select="tei:stage[1]/node()"/>
        </span>
      </xsl:if>
    </h4>

    <!-- rest of the speech (lines, later stage directions, etc.) -->
    <xsl:apply-templates select="
          node()[not(self::tei:speaker)]
                 [not(position() = 1 and self::tei:stage)]"/>
  </div>
</xsl:template>


   <!-- 3.  Lines & prose -->

<!-- verse line -->
<xsl:template match="tei:l">
  <p class="line"
     id="l-{@n}"          
     data-ln="{@n}">       
    <xsl:apply-templates/>
  </p>
</xsl:template>


  <!-- prose paragraph -->
  <xsl:template match="tei:p">
    <p class="para"><xsl:apply-templates/></p>
  </xsl:template>

<!-- ────────────────────────────────────────────────────────────────
     3.  Line‑breaks inside prose
     ────────────────────────────────────────────────────────────────-->

<!-- 1️⃣  SUPPRESS the very first <lb/> that appears inside any element -->
<xsl:template match="tei:lb[not(preceding-sibling::*)]" priority="1"/>

<!-- 2️⃣  Turn every other <lb/> into a real break -->
<xsl:template match="tei:lb">
  <br/>
</xsl:template>



  <!-- explicit spaces -->
  <xsl:template match="tei:c[@type='space']">
    <xsl:text> </xsl:text>
  </xsl:template>

  <!-- 5.  Pagination & line numbers (hidden unless shown by CSS) -->

  <xsl:template match="tei:pb">
    <span class="pb" data-page="{@n}"></span>
  </xsl:template>

  <xsl:template match="tei:milestone[@unit='ftln']">
    <span class="ln" id="ftln{@n}"></span>
  </xsl:template>


</xsl:stylesheet>
